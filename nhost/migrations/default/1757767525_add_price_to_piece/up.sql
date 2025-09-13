-- Add price field to piece table
ALTER TABLE potterbase.piece 
ADD COLUMN price DECIMAL(10,2);

-- Add a comment to document the new field
COMMENT ON COLUMN potterbase.piece.price IS 'Price of the pottery piece in dollars';
