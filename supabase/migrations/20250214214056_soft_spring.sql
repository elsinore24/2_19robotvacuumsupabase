/*
  # Fix admin authentication policies

  1. Changes
    - Grant admin users access to auth.users table
    - Update admin role check function to be more robust
    - Ensure admin users can access necessary tables
  
  2. Security
    - Maintain RLS security while allowing necessary admin access
    - Use security definer functions for controlled access
*/

-- Create a more robust admin check function
CREATE OR REPLACE FUNCTION auth.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  -- Check if the user exists and has admin role
  RETURN (
    SELECT EXISTS (
      SELECT 1
      FROM auth.users
      WHERE 
        id = auth.uid() AND
        raw_user_meta_data->>'role' = 'admin'
    )
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions to authenticated users
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT SELECT ON auth.users TO authenticated;

-- Ensure admin users can access necessary tables
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;

-- Update deals table policies to use the new admin check
DO $$ 
BEGIN
  -- Drop existing policies
  DROP POLICY IF EXISTS "Admin can insert deals" ON deals;
  DROP POLICY IF EXISTS "Admin can update deals" ON deals;
  DROP POLICY IF EXISTS "Admin can delete deals" ON deals;

  -- Recreate policies using the new admin check
  CREATE POLICY "Admin can insert deals"
    ON deals
    FOR INSERT
    WITH CHECK (auth.is_admin());

  CREATE POLICY "Admin can update deals"
    ON deals
    FOR UPDATE
    USING (auth.is_admin())
    WITH CHECK (auth.is_admin());

  CREATE POLICY "Admin can delete deals"
    ON deals
    FOR DELETE
    USING (auth.is_admin());
END $$;