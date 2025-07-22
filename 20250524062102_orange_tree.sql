/*
  # Create PG listings schema
  
  1. New Tables
    - `pg_listings`
      - `id` (uuid, primary key)
      - `owner_id` (uuid, references auth.users)
      - `name` (text)
      - `description` (text)
      - `location` (text)
      - `city` (text)
      - `address` (text)
      - `price` (integer)
      - `gender` (text)
      - `amenities` (text[])
      - `images` (text[])
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
  
  2. Security
    - Enable RLS on `pg_listings` table
    - Add policies for:
      - Owners can read/write their own listings
      - Anyone can read published listings
*/

CREATE TABLE IF NOT EXISTS pg_listings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid REFERENCES auth.users NOT NULL,
  name text NOT NULL,
  description text,
  location text NOT NULL,
  city text NOT NULL,
  address text NOT NULL,
  price integer NOT NULL,
  gender text NOT NULL,
  amenities text[] DEFAULT '{}',
  images text[] DEFAULT '{}',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE pg_listings ENABLE ROW LEVEL SECURITY;

-- Allow owners to manage their listings
CREATE POLICY "Owners can manage their listings"
  ON pg_listings
  FOR ALL
  TO authenticated
  USING (auth.uid() = owner_id)
  WITH CHECK (auth.uid() = owner_id);

-- Allow public read access
CREATE POLICY "Anyone can view listings"
  ON pg_listings
  FOR SELECT
  TO anon, authenticated
  USING (true);