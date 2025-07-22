-- Drop existing foreign key constraints if they exist
ALTER TABLE property_reviews 
DROP CONSTRAINT IF EXISTS property_reviews_user_id_fkey;

-- Add proper foreign key constraint to auth.users
ALTER TABLE property_reviews
ADD CONSTRAINT property_reviews_user_id_fkey 
FOREIGN KEY (user_id) REFERENCES auth.users(id);

-- Update the review query structure
CREATE OR REPLACE FUNCTION get_user_name(user_id uuid)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
AS $$
  SELECT raw_user_meta_data->>'full_name'
  FROM auth.users
  WHERE id = user_id;
$$;