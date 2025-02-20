/*
  # Add admin role and policies

  1. Changes
    - Add admin role check function
    - Update delete policy to only allow admin users
    - Remove public delete access

  2. Security
    - Only authenticated admin users can delete deals
    - Public users can still read deals
    - Maintains existing insert policies
*/

-- Create a function to check if a user has admin role
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM auth.users
    WHERE id = auth.uid()
    AND raw_user_meta_data->>'role' = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Remove existing delete policy
DROP POLICY IF EXISTS "Public can delete deals" ON deals;

-- Create new admin-only delete policy
CREATE POLICY "Admin users can delete deals"
  ON deals
  FOR DELETE
  USING (auth.is_admin());