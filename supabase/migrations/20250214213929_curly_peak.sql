/*
  # Fix deals table RLS policies

  1. Changes
    - Drop all existing policies on deals table
    - Create new policies:
      - Allow public read access
      - Restrict write operations to admin users
  
  2. Security
    - Enable RLS on deals table
    - Public can only read deals
    - Only admin users can insert, update, and delete deals
*/

-- Safely update deals table policies
DO $$ 
BEGIN
  -- Drop all existing policies
  DROP POLICY IF EXISTS "Public can read deals" ON deals;
  DROP POLICY IF EXISTS "Public can insert deals" ON deals;
  DROP POLICY IF EXISTS "Public can update deals" ON deals;
  DROP POLICY IF EXISTS "Public can delete deals" ON deals;
  DROP POLICY IF EXISTS "Admin can update deals" ON deals;
  DROP POLICY IF EXISTS "Admin can delete deals" ON deals;
  DROP POLICY IF EXISTS "Anyone can read deals" ON deals;
  DROP POLICY IF EXISTS "Authenticated users can insert deals" ON deals;

  -- Create new policies
  
  -- Allow public read access
  CREATE POLICY "Public can read deals"
    ON deals
    FOR SELECT
    USING (true);

  -- Restrict write operations to admin users
  CREATE POLICY "Admin can insert deals"
    ON deals
    FOR INSERT
    WITH CHECK (auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE raw_user_meta_data->>'role' = 'admin'
    ));

  CREATE POLICY "Admin can update deals"
    ON deals
    FOR UPDATE
    USING (auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE raw_user_meta_data->>'role' = 'admin'
    ))
    WITH CHECK (auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE raw_user_meta_data->>'role' = 'admin'
    ));

  CREATE POLICY "Admin can delete deals"
    ON deals
    FOR DELETE
    USING (auth.uid() IN (
      SELECT id FROM auth.users 
      WHERE raw_user_meta_data->>'role' = 'admin'
    ));
END $$;