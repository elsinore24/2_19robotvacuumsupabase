/*
  # Add model number and suction power columns to deals table

  1. Changes
    - Add `model_number` column (text)
    - Add `suction_power` column (integer)
    Both columns are nullable to maintain compatibility with existing records
*/

DO $$ 
BEGIN
  -- Add model_number column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'deals' AND column_name = 'model_number'
  ) THEN
    ALTER TABLE deals ADD COLUMN model_number text;
  END IF;

  -- Add suction_power column if it doesn't exist
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'deals' AND column_name = 'suction_power'
  ) THEN
    ALTER TABLE deals ADD COLUMN suction_power integer;
  END IF;
END $$;