-- Create cart table for shopping cart items
CREATE TABLE IF NOT EXISTS potterbase.cart (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    piece_id INTEGER NOT NULL REFERENCES potterbase.piece(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE(user_id, piece_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_cart_user_id ON potterbase.cart(user_id);
CREATE INDEX IF NOT EXISTS idx_cart_piece_id ON potterbase.cart(piece_id);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION potterbase.update_cart_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cart_updated_at
    BEFORE UPDATE ON potterbase.cart
    FOR EACH ROW
    EXECUTE FUNCTION potterbase.update_cart_updated_at();

COMMENT ON TABLE potterbase.cart IS 'Shopping cart items for ecommerce functionality';

