-- Add test_tile_image_url column to glaze table
ALTER TABLE potterbase.glaze 
ADD COLUMN IF NOT EXISTS test_tile_image_url TEXT;


