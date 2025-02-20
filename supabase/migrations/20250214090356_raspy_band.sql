/*
  # Update unique constraint for model number and price

  1. Changes
    - Add unique constraint on model_number and price combination
    - This prevents duplicate products with the same model number and price
    
  2. Notes
    - Only applies when model_number is not null
    - Partial index allows multiple null model_numbers
*/

-- Drop any existing index if it exists
DROP INDEX IF EXISTS deals_model_brand_unique;

-- Create new unique index on model_number and price
CREATE UNIQUE INDEX IF NOT EXISTS deals_model_price_unique 
ON deals (model_number, price) 
WHERE model_number IS NOT NULL;