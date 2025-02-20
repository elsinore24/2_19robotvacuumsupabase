/*
  # Add admin authentication

  1. Changes
    - Add admin_auth table for storing hashed admin password
    - Add function to verify admin password
    - Update RLS policies to use password verification
*/

-- Create admin_auth table
CREATE TABLE IF NOT EXISTS admin_auth (
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