-- Update robot_vacuums table schema

-- Drop existing check constraints on score columns
ALTER TABLE robot_vacuums
  DROP CONSTRAINT IF EXISTS robot_vacuums_cleaning_score_check,
  DROP CONSTRAINT IF EXISTS robot_vacuums_navigation_score_check,
  DROP CONSTRAINT IF EXISTS robot_vacuums_smart_score_check,
  DROP CONSTRAINT IF EXISTS robot_vacuums_maintenance_score_check,
  DROP CONSTRAINT IF EXISTS robot_vacuums_battery_score_check,
  DROP CONSTRAINT IF EXISTS robot_vacuums_pet_family_score_check,
  DROP CONSTRAINT IF EXISTS robot_vacuums_review_score_check,
  DROP CONSTRAINT IF EXISTS robot_vacuums_cleaniq_score_check;

-- Modify score columns to use numeric type for decimal values
ALTER TABLE robot_vacuums
  ALTER COLUMN cleaning_score TYPE numeric USING cleaning_score::numeric,
  ALTER COLUMN navigation_score TYPE numeric USING navigation_score::numeric,
  ALTER COLUMN smart_score TYPE numeric USING smart_score::numeric,
  ALTER COLUMN maintenance_score TYPE numeric USING maintenance_score::numeric,
  ALTER COLUMN battery_score TYPE numeric USING battery_score::numeric,
  ALTER COLUMN pet_family_score TYPE numeric USING pet_family_score::numeric,
  ALTER COLUMN review_score TYPE numeric USING review_score::numeric,
  ALTER COLUMN cleaniq_score TYPE numeric USING cleaniq_score::numeric;

-- Add new check constraints for score ranges (0-10)
ALTER TABLE robot_vacuums
  ADD CONSTRAINT robot_vacuums_cleaning_score_check CHECK (cleaning_score >= 0 AND cleaning_score <= 10),
  ADD CONSTRAINT robot_vacuums_navigation_score_check CHECK (navigation_score >= 0 AND navigation_score <= 10),
  ADD CONSTRAINT robot_vacuums_smart_score_check CHECK (smart_score >= 0 AND smart_score <= 10),
  ADD CONSTRAINT robot_vacuums_maintenance_score_check CHECK (maintenance_score >= 0 AND maintenance_score <= 10),
  ADD CONSTRAINT robot_vacuums_battery_score_check CHECK (battery_score >= 0 AND battery_score <= 10),
  ADD CONSTRAINT robot_vacuums_pet_family_score_check CHECK (pet_family_score >= 0 AND pet_family_score <= 10),
  ADD CONSTRAINT robot_vacuums_review_score_check CHECK (review_score >= 0 AND review_score <= 10),
  ADD CONSTRAINT robot_vacuums_cleaniq_score_check CHECK (cleaniq_score >= 0 AND cleaniq_score <= 10);

-- Modify reviews column to use numeric for decimal values
ALTER TABLE robot_vacuums
  ALTER COLUMN reviews TYPE numeric USING reviews::numeric;

-- Add check constraint for reviews range (0-5)
ALTER TABLE robot_vacuums
  ADD CONSTRAINT robot_vacuums_reviews_check CHECK (reviews >= 0 AND reviews <= 5);

-- Update boolean columns to have proper defaults for N/A values
ALTER TABLE robot_vacuums
  ALTER COLUMN side_brush SET DEFAULT false,
  ALTER COLUMN dual_brush SET DEFAULT false,
  ALTER COLUMN tangle_free SET DEFAULT false,
  ALTER COLUMN wifi SET DEFAULT false,
  ALTER COLUMN scheduling SET DEFAULT false,
  ALTER COLUMN zone_cleaning SET DEFAULT false,
  ALTER COLUMN spot_cleaning SET DEFAULT false,
  ALTER COLUMN auto_boost SET DEFAULT false,
  ALTER COLUMN maintenance_reminder SET DEFAULT false,
  ALTER COLUMN filter_replacement_indicator SET DEFAULT false,
  ALTER COLUMN brush_cleaning_indicator SET DEFAULT false,
  ALTER COLUMN large_dustbin SET DEFAULT false,
  ALTER COLUMN auto_empty_base SET DEFAULT false,
  ALTER COLUMN washable_dustbin SET DEFAULT false,
  ALTER COLUMN washable_filter SET DEFAULT false,
  ALTER COLUMN easy_brush_removal SET DEFAULT false,
  ALTER COLUMN self_cleaning_brushroll SET DEFAULT false,
  ALTER COLUMN dustbin_full_indicator SET DEFAULT false;