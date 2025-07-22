/*
  # Fix review policies and relationships

  1. Changes
    - Update RLS policies for property_reviews table to allow verified residents to submit reviews
    - Add policy for users to view all reviews

  2. Security
    - Enable RLS on property_reviews table
    - Add policy for verified residents to submit reviews
    - Add policy for anyone to view reviews
*/

-- First, enable RLS if not already enabled
ALTER TABLE property_reviews ENABLE ROW LEVEL SECURITY;

-- Drop existing policies to recreate them
DROP POLICY IF EXISTS "Anyone can view reviews" ON property_reviews;
DROP POLICY IF EXISTS "Verified residents can create reviews" ON property_reviews;

-- Create policy for viewing reviews (anyone can view)
CREATE POLICY "Anyone can view reviews"
ON property_reviews
FOR SELECT
TO public
USING (true);

-- Create policy for creating reviews (only verified residents)
CREATE POLICY "Verified residents can create reviews"
ON property_reviews
FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM verified_residents
    WHERE verified_residents.user_id = auth.uid()
    AND verified_residents.property_id = property_reviews.property_id
    AND verified_residents.verified_at IS NOT NULL
    AND verified_residents.valid_until > now()
  )
);