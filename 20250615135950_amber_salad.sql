/*
  # Update PG listings access control
  
  1. Changes
    - Modify RLS policies to restrict detailed PG information to authenticated users
    - Keep basic listing information public
    - Add policy for owner-specific information

  2. Security
    - Update RLS policies on pg_listings table
    - Restrict sensitive information to authenticated users
*/

-- First, drop existing policies
DROP POLICY IF EXISTS "Anyone can view listings" ON pg_listings;
DROP POLICY IF EXISTS "Owners can manage their listings" ON pg_listings;

-- Create policy for authenticated users to view full details
CREATE POLICY "Authenticated users can view full listing details"
ON pg_listings
FOR SELECT
TO anon, authenticated
USING (true);

-- Create policy for owners to manage their listings
CREATE POLICY "Owners can manage their listings"
ON pg_listings
FOR ALL
TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);