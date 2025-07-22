/*
  # Create saved properties table
  
  1. New Tables
    - `saved_properties`
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `property_id` (uuid, references pg_listings)
      - `created_at` (timestamp)
  
  2. Security
    - Enable RLS on `saved_properties` table
    - Add policies for authenticated users to manage their saved properties
*/

CREATE TABLE IF NOT EXISTS saved_properties (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users NOT NULL,
  property_id uuid REFERENCES pg_listings NOT NULL,
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id, property_id)
);

ALTER TABLE saved_properties ENABLE ROW LEVEL SECURITY;

-- Allow users to manage their saved properties
CREATE POLICY "Users can manage their saved properties"
  ON saved_properties
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);