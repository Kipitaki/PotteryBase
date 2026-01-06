-- Add application_order column to piece_glaze table
ALTER TABLE bandanas.piece_glaze 
ADD COLUMN application_order INTEGER DEFAULT 1;

-- Update existing records to have sequential order numbers
-- This will assign order numbers 1, 2, 3, etc. based on layer_number
UPDATE bandanas.piece_glaze 
SET application_order = subquery.row_number
FROM (
  SELECT id, ROW_NUMBER() OVER (PARTITION BY piece_id ORDER BY layer_number ASC) as row_number
  FROM bandanas.piece_glaze
) subquery
WHERE bandanas.piece_glaze.id = subquery.id;
