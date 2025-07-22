/*
  # Update PG listings table
  
  1. Add Columns
    - `landmark` (text)
    - `owner_name` (text)
    - `owner_phone` (text)
  
  2. Security
    - Existing RLS policies will apply to new columns
*/

ALTER TABLE pg_listings
ADD COLUMN IF NOT EXISTS landmark text,
ADD COLUMN IF NOT EXISTS owner_name text,
ADD COLUMN IF NOT EXISTS owner_phone text;