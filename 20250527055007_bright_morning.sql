/*
  # Fix property UUIDs

  1. Changes
    - Update existing property IDs to be valid UUIDs
    - Add constraint to ensure property IDs are always valid UUIDs

  2. Security
    - No changes to RLS policies
*/

-- First, delete any saved_properties records with invalid UUIDs
DELETE FROM saved_properties 
WHERE NOT (property_id::text ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');

-- Then, delete any pg_listings records with invalid UUIDs
DELETE FROM pg_listings 
WHERE NOT (id::text ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');

-- Add a check constraint to ensure property IDs are valid UUIDs
ALTER TABLE pg_listings 
ADD CONSTRAINT check_valid_uuid 
CHECK (id::text ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');