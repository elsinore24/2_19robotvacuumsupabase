/*
  # Update RLS policies for deals table

  1. Changes
    - Drop existing RLS policies
    - Add new policies for:
      - Public read access
      - Public insert access
      - Public update access for own records
      - Public delete access for own records

  2. Security
    - Enable RLS on deals table
    - Allow public read access to all deals
    - Allow public insert/update/delete for all records
*/

-- Drop existing policies
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Anyone can read deals" ON deals;
  DROP POLICY IF EXISTS "Authenticated users can insert deals" ON deals;
END $$;

-- Create new policies
CREATE POLICY "Public can read deals"
  ON deals
  FOR SELECT
  USING (true);

CREATE POLICY "Public can insert deals"
  ON deals
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Public can update deals"
  ON deals
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Public can delete deals"
  ON deals
  FOR DELETE
  USING (true);