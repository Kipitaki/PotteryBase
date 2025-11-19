-- Add pages column to potterbase.glaze table
ALTER TABLE potterbase.glaze
ADD COLUMN IF NOT EXISTS pages TEXT;


