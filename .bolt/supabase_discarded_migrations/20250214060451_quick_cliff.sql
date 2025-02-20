/*
  # Add brand preferences column to deals table

  1. Changes
    - Add brand_preferences column to deals table
      - JSON type to store brand-specific preferences
      - Nullable
      - Default empty JSON object

  2. Notes
    - Uses JSONB for better performance and indexing
    - Allows flexible storage of brand-specific settings
*/

-- Add brand_preferences column if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.columns 
    WHERE table_name = 'deals' 
    AND column_name = 'brand_preferences'
  ) THEN
    ALTER TABLE deals 
    ADD COLUMN brand_preferences JSONB DEFAULT '{}'::jsonb;
  END IF;
END $$;

-- Add index for brand_preferences to improve query performance
CREATE INDEX IF NOT EXISTS idx_deals_brand_preferences 
ON deals USING GIN (brand_preferences);

-- Add comment to explain the column usage
COMMENT ON COLUMN deals.brand_preferences IS 'Store brand-specific preferences and settings in JSON format';