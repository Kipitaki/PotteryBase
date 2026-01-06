ALTER TABLE potterbase.events
ADD COLUMN IF NOT EXISTS image_url TEXT;
COMMENT ON COLUMN potterbase.events.image_url IS 'URL to the bandana image (square image)';



