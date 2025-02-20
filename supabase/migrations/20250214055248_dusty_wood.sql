/*
  # Update deals table schema
  
  1. Changes
    - Create deals table if it doesn't exist
    - Add proper column types and constraints
    - Enable RLS policies
  
  2. Security
    - Enable RLS on deals table
    - Add policies for read and insert operations (if they don't exist)
*/

-- Create the deals table if it doesn't exist
CREATE TABLE IF NOT EXISTS deals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  price numeric NOT NULL,
  image_url text,
  deal_url text NOT NULL,
  brand text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist and recreate them
DO $$ 
BEGIN
  -- Drop existing policies if they exist
  DROP POLICY IF EXISTS "Anyone can read deals" ON deals;
  DROP POLICY IF EXISTS "Authenticated users can insert deals" ON deals;
  
  -- Create new policies
  CREATE POLICY "Anyone can read deals"
    ON deals
    FOR SELECT
    TO authenticated
    USING (true);

  CREATE POLICY "Authenticated users can insert deals"
    ON deals
    FOR INSERT
    TO authenticated
    WITH CHECK (true);
END $$;

-- Create or replace the update timestamp function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Drop the trigger if it exists and recreate it
DROP TRIGGER IF EXISTS update_deals_updated_at ON deals;
CREATE TRIGGER update_deals_updated_at
  BEFORE UPDATE ON deals
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();