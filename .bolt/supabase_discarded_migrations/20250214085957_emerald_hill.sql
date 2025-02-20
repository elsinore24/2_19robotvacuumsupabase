/*
  # Add unique constraint for model number and brand

  1. Changes
    - Add unique constraint on model_number and brand combination
    - This prevents duplicate products from being inserted
    
  2. Notes
    - Only applies when model_number is not null
    - Partial index allows multiple null model_numbers
*/

CREATE UNIQUE INDEX IF NOT EXISTS deals_model_brand_unique 
ON deals (model_number, brand) 
WHERE model_number IS NOT NULL;