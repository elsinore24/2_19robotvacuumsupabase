/*
  # Fix admin authentication setup

  1. Changes
    - Enable required extensions
    - Set up admin authentication tables and functions
    - Create initial admin user
    - Update RLS policies with proper error handling
*/

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop existing objects to ensure clean setup
DROP FUNCTION IF EXISTS verify_admin_password(text);
DROP TABLE IF EXISTS admin_auth CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;

-- Create admin_auth table
CREATE TABLE admin_auth (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  password_hash text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Function to verify admin password
CREATE OR REPLACE FUNCTION verify_admin_password(input_password text)
RETURNS BOOLEAN AS $$
DECLARE
  stored_hash text;
BEGIN
  SELECT password_hash INTO stored_hash FROM admin_auth LIMIT 1;
  RETURN stored_hash = crypt(input_password, stored_hash);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Insert initial admin password (default: admin123)
INSERT INTO admin_auth (password_hash)
VALUES (crypt('admin123', gen_salt('bf')));

-- Enable RLS
ALTER TABLE admin_auth ENABLE ROW LEVEL SECURITY;

-- Only allow admin to access admin_auth table
CREATE POLICY "No public access to admin_auth"
  ON admin_auth
  FOR ALL
  USING (false);

-- Create admin_users table
CREATE TABLE admin_users (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  email text UNIQUE NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Insert default admin user
INSERT INTO admin_users (email)
VALUES ('admin@example.com')
ON CONFLICT (email) DO NOTHING;

-- Enable RLS on admin_users
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- Create policy to allow admin access
CREATE POLICY "Allow admin access"
  ON admin_users
  FOR ALL
  USING (auth.uid() IN (SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'));

-- Safely update deals table policies
DO $$ 
BEGIN
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Public can update deals" ON deals;
  DROP POLICY IF EXISTS "Public can delete deals" ON deals;
  DROP POLICY IF EXISTS "Admin can update deals" ON deals;
  DROP POLICY IF EXISTS "Admin can delete deals" ON deals;

  -- Create new policies
  CREATE POLICY "Admin can update deals"
    ON deals
    FOR UPDATE
    USING (auth.uid() IN (SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'))
    WITH CHECK (auth.uid() IN (SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'));

  CREATE POLICY "Admin can delete deals"
    ON deals
    FOR DELETE
    USING (auth.uid() IN (SELECT id FROM auth.users WHERE raw_user_meta_data->>'role' = 'admin'));
END $$;