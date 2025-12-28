-- Remove test_tile_image_url column from glaze table
ALTER TABLE potterbase.glaze 
DROP COLUMN IF EXISTS test_tile_image_url;


