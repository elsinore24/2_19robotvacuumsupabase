/*
  # Create robot_vacuums table

  1. New Tables
    - `robot_vacuums`
      - Basic Information:
        - id (uuid, primary key)
        - brand (text)
        - model_number (text)
        - title (text)
        - description (text)
        - price (numeric)
        - reviews (numeric)
        - image_url (text)
        - deal_url (text)
      
      - Technical Specifications:
        - suction_power (integer)
        - battery_minutes (integer)
        - navigation_type (text)
        - noise_level (integer)
      
      - Boolean Features:
        - self_empty
        - mopping
        - hepa_filter
        - edge_cleaning
        - side_brush
        - dual_brush
        - tangle_free
        - wifi
        - app_control
        - voice_control
        - scheduling
        - zone_cleaning
        - spot_cleaning
        - no_go_zones
        - auto_boost
        - object_recognition
        - furniture_recognition
        - pet_recognition
        - three_d_mapping
        - obstacle_avoidance
        - uv_sterilization
        - maintenance_reminder
        - filter_replacement_indicator
        - brush_cleaning_indicator
        - large_dustbin
        - auto_empty_base
        - washable_dustbin
        - washable_filter
        - easy_brush_removal
        - self_cleaning_brushroll
        - dustbin_full_indicator
      
      - Scores:
        - cleaning_score (numeric)
        - navigation_score (numeric)
        - smart_score (numeric)
        - maintenance_score (numeric)
        - battery_score (numeric)
        - pet_family_score (numeric)
        - review_score (numeric)
        - cleaniq_score (numeric)

  2. Security
    - Enable RLS on `robot_vacuums` table
    - Public read access
    - Admin-only write access

  3. Indexes
    - brand
    - price
    - model_number
    - cleaniq_score
*/

-- Drop existing table if it exists
DROP TABLE IF EXISTS robot_vacuums CASCADE;

-- Create robot_vacuums table
CREATE TABLE robot_vacuums (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Basic Information
  brand text NOT NULL,
  model_number text NOT NULL,
  title text NOT NULL,
  description text,
  price numeric NOT NULL,
  reviews numeric CHECK (reviews >= 0 AND reviews <= 5),
  image_url text,
  deal_url text NOT NULL,
  
  -- Technical Specifications
  suction_power integer,
  battery_minutes integer,
  navigation_type text,
  noise_level integer,
  
  -- Boolean Features
  self_empty boolean DEFAULT false,
  mopping boolean DEFAULT false,
  hepa_filter boolean DEFAULT false,
  edge_cleaning boolean DEFAULT false,
  side_brush boolean DEFAULT false,
  dual_brush boolean DEFAULT false,
  tangle_free boolean DEFAULT false,
  wifi boolean DEFAULT false,
  app_control boolean DEFAULT false,
  voice_control boolean DEFAULT false,
  scheduling boolean DEFAULT false,
  zone_cleaning boolean DEFAULT false,
  spot_cleaning boolean DEFAULT false,
  no_go_zones boolean DEFAULT false,
  auto_boost boolean DEFAULT false,
  object_recognition boolean DEFAULT false,
  furniture_recognition boolean DEFAULT false,
  pet_recognition boolean DEFAULT false,
  three_d_mapping boolean DEFAULT false,
  obstacle_avoidance boolean DEFAULT false,
  uv_sterilization boolean DEFAULT false,
  maintenance_reminder boolean DEFAULT false,
  filter_replacement_indicator boolean DEFAULT false,
  brush_cleaning_indicator boolean DEFAULT false,
  large_dustbin boolean DEFAULT false,
  auto_empty_base boolean DEFAULT false,
  washable_dustbin boolean DEFAULT false,
  washable_filter boolean DEFAULT false,
  easy_brush_removal boolean DEFAULT false,
  self_cleaning_brushroll boolean DEFAULT false,
  dustbin_full_indicator boolean DEFAULT false,
  
  -- Scores (0-10)
  cleaning_score numeric CHECK (cleaning_score >= 0 AND cleaning_score <= 10),
  navigation_score numeric CHECK (navigation_score >= 0 AND navigation_score <= 10),
  smart_score numeric CHECK (smart_score >= 0 AND smart_score <= 10),
  maintenance_score numeric CHECK (maintenance_score >= 0 AND maintenance_score <= 10),
  battery_score numeric CHECK (battery_score >= 0 AND battery_score <= 10),
  pet_family_score numeric CHECK (pet_family_score >= 0 AND pet_family_score <= 10),
  review_score numeric CHECK (review_score >= 0 AND review_score <= 10),
  cleaniq_score numeric CHECK (cleaniq_score >= 0 AND cleaniq_score <= 10),
  
  -- Metadata
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  
  -- Constraints
  CONSTRAINT unique_model_number UNIQUE (model_number)
);

-- Enable row level security
ALTER TABLE robot_vacuums ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public can read robot_vacuums"
  ON robot_vacuums
  FOR SELECT
  USING (true);

CREATE POLICY "Admin can insert robot_vacuums"
  ON robot_vacuums
  FOR INSERT
  WITH CHECK (auth.is_admin());

CREATE POLICY "Admin can update robot_vacuums"
  ON robot_vacuums
  FOR UPDATE
  USING (auth.is_admin())
  WITH CHECK (auth.is_admin());

CREATE POLICY "Admin can delete robot_vacuums"
  ON robot_vacuums
  FOR DELETE
  USING (auth.is_admin());

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION update_robot_vacuums_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_robot_vacuums_updated_at
  BEFORE UPDATE ON robot_vacuums
  FOR EACH ROW
  EXECUTE FUNCTION update_robot_vacuums_updated_at();

-- Create indexes for common queries
CREATE INDEX idx_robot_vacuums_brand ON robot_vacuums (brand);
CREATE INDEX idx_robot_vacuums_price ON robot_vacuums (price);
CREATE INDEX idx_robot_vacuums_model_number ON robot_vacuums (model_number);
CREATE INDEX idx_robot_vacuums_cleaniq_score ON robot_vacuums (cleaniq_score);