/*
  # Robot Vacuum Database Schema

  1. New Tables
    - `robot_vacuums` table with comprehensive vacuum cleaner specifications and scores
      - Basic Info: brand, model, price, etc.
      - Technical Specs: suction power, battery life, etc.
      - Features: self-empty, mopping, HEPA filter, etc.
      - Scores: cleaning, navigation, smart features, etc.

  2. Security
    - Enable RLS
    - Add policies for public read access
    - Add policies for admin write access
*/

-- Create the robot_vacuums table
CREATE TABLE IF NOT EXISTS robot_vacuums (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  -- Basic Information
  brand text NOT NULL,
  model_number text NOT NULL,
  title text NOT NULL,
  description text,
  price numeric NOT NULL,
  reviews integer DEFAULT 0,
  image_url text,
  deal_url text NOT NULL,
  
  -- Technical Specifications
  suction_power integer, -- in Pa
  battery_minutes integer,
  navigation_type text,
  noise_level integer, -- in dB
  
  -- Core Features
  self_empty boolean DEFAULT false,
  mopping boolean DEFAULT false,
  hepa_filter boolean DEFAULT false,
  edge_cleaning boolean DEFAULT false,
  side_brush boolean DEFAULT false,
  dual_brush boolean DEFAULT false,
  tangle_free boolean DEFAULT false,
  
  -- Smart Features
  wifi boolean DEFAULT false,
  app_control boolean DEFAULT false,
  voice_control boolean DEFAULT false,
  scheduling boolean DEFAULT false,
  zone_cleaning boolean DEFAULT false,
  spot_cleaning boolean DEFAULT false,
  no_go_zones boolean DEFAULT false,
  auto_boost boolean DEFAULT false,
  
  -- Advanced Features
  object_recognition boolean DEFAULT false,
  furniture_recognition boolean DEFAULT false,
  pet_recognition boolean DEFAULT false,
  three_d_mapping boolean DEFAULT false,
  obstacle_avoidance boolean DEFAULT false,
  uv_sterilization boolean DEFAULT false,
  
  -- Maintenance Features
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
  
  -- Scores (0-100)
  cleaning_score integer CHECK (cleaning_score BETWEEN 0 AND 100),
  navigation_score integer CHECK (navigation_score BETWEEN 0 AND 100),
  smart_score integer CHECK (smart_score BETWEEN 0 AND 100),
  maintenance_score integer CHECK (maintenance_score BETWEEN 0 AND 100),
  battery_score integer CHECK (battery_score BETWEEN 0 AND 100),
  pet_family_score integer CHECK (pet_family_score BETWEEN 0 AND 100),
  review_score integer CHECK (review_score BETWEEN 0 AND 100),
  cleaniq_score integer CHECK (cleaniq_score BETWEEN 0 AND 100),
  
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
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_robot_vacuums_updated_at
  BEFORE UPDATE ON robot_vacuums
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for common queries
CREATE INDEX idx_robot_vacuums_brand ON robot_vacuums (brand);
CREATE INDEX idx_robot_vacuums_price ON robot_vacuums (price);
CREATE INDEX idx_robot_vacuums_cleaniq_score ON robot_vacuums (cleaniq_score);