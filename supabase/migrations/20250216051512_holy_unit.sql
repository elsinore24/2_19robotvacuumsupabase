/*
  # Admin Authentication System

  1. Changes
    - Create admin_auth table for secure password storage
    - Add function to verify admin password
    - Set up RLS policies
    
  2. Security
    - Use pgcrypto for password hashing
    - Enable RLS
    - Restrict access to admin users
*/

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Drop existing objects if they exist
DROP TABLE IF EXISTS admin_auth CASCADE;
DROP FUNCTION IF EXISTS verify_admin_credentials(text, text);

-- Create admin_auth table
CREATE TABLE admin_auth (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password_hash text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_admin_auth_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_admin_auth_updated_at
  BEFORE UPDATE ON admin_auth
  FOR EACH ROW
  EXECUTE FUNCTION update_admin_auth_updated_at();

-- Function to verify admin credentials
CREATE OR REPLACE FUNCTION verify_admin_credentials(input_email text, input_password text)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM admin_auth
    WHERE email = input_email
    AND password_hash = crypt(input_password, password_hash)
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Insert default admin user (email: admin@example.com, password: admin123)
INSERT INTO admin_auth (email, password_hash)
VALUES (
  'admin@example.com',
  crypt('admin123', gen_salt('bf'))
)
ON CONFLICT (email) DO UPDATE
SET password_hash = EXCLUDED.password_hash;

-- Enable RLS
ALTER TABLE admin_auth ENABLE ROW LEVEL SECURITY;

-- Create policy for admin access
CREATE POLICY "Admin users can access their own data"
  ON admin_auth
  FOR ALL
  USING (auth.uid() IN (
    SELECT id FROM auth.users 
    WHERE email = current_setting('request.jwt.claims')::json->>'email'
  ));