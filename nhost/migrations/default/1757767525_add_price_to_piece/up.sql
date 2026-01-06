-- Add price field to piece table (only if it doesn't exist)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'potterbase' 
        AND table_name = 'piece' 
        AND column_name = 'price'
    ) THEN
        ALTER TABLE bandanas.piece ADD COLUMN price DECIMAL(10,2);
        COMMENT ON COLUMN bandanas.piece.price IS 'Price of the pottery piece in dollars';
    END IF;
END $$;
