/*
  # Add verified residents and reviews tables
  
  1. New Tables
    - `verified_residents`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `property_id` (uuid, references pg_listings)
      - `receipt_url` (text)
      - `verified_at` (timestamp)
      - `valid_until` (timestamp)
      - `created_at` (timestamp)
    
    - `property_reviews`
      - `id` (uuid, primary key)
      - `property_id` (uuid, references pg_listings)
      - `user_id` (uuid, references auth.users)
      - `rating` (integer)
      - `comment` (text)
      - `stay_duration` (text)
      - `created_at` (timestamp)
  
  2. Security
    - Enable RLS on both tables
    - Add policies for verified residents
*/

-- Create verified residents table
CREATE TABLE IF NOT EXISTS verified_residents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users NOT NULL,
  property_id uuid REFERENCES pg_listings NOT NULL,
  receipt_url text NOT NULL,
  verified_at timestamptz,
  valid_until timestamptz,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, property_id)
);

-- Create property reviews table
CREATE TABLE IF NOT EXISTS property_reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  property_id uuid REFERENCES pg_listings NOT NULL,
  user_id uuid REFERENCES auth.users NOT NULL,
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text NOT NULL,
  stay_duration text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE verified_residents ENABLE ROW LEVEL SECURITY;
ALTER TABLE property_reviews ENABLE ROW LEVEL SECURITY;

-- Policies for verified residents
CREATE POLICY "Users can view their own verification status"
  ON verified_residents
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Users can submit verification requests"
  ON verified_residents
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

-- Policies for property reviews
CREATE POLICY "Anyone can view reviews"
  ON property_reviews
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Verified residents can create reviews"
  ON property_reviews
  FOR INSERT
  TO authenticated
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM verified_residents
      WHERE user_id = auth.uid()
        AND property_id = property_reviews.property_id
        AND verified_at IS NOT NULL
        AND valid_until > now()
    )
  );