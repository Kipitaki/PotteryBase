-- Add ecommerce fields to piece table
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'potterbase' 
        AND table_name = 'piece' 
        AND column_name = 'is_for_sale'
    ) THEN
        ALTER TABLE potterbase.piece ADD COLUMN is_for_sale BOOLEAN NOT NULL DEFAULT false;
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'potterbase' 
        AND table_name = 'piece' 
        AND column_name = 'in_stock'
    ) THEN
        ALTER TABLE potterbase.piece ADD COLUMN in_stock BOOLEAN NOT NULL DEFAULT true;
    END IF;
END $$;

-- Create index for faster filtering of items for sale
CREATE INDEX IF NOT EXISTS idx_piece_is_for_sale ON potterbase.piece(is_for_sale) WHERE is_for_sale = true;
CREATE INDEX IF NOT EXISTS idx_piece_in_stock ON potterbase.piece(in_stock) WHERE in_stock = true;

COMMENT ON COLUMN potterbase.piece.is_for_sale IS 'Whether this piece is available for purchase';
COMMENT ON COLUMN potterbase.piece.in_stock IS 'Whether this piece is currently in stock';

