-- Create order table
CREATE TABLE IF NOT EXISTS potterbase."order" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
    order_number TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'processing', 'shipped', 'delivered', 'cancelled')),
    subtotal DECIMAL(10,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    shipping_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
    total DECIMAL(10,2) NOT NULL DEFAULT 0,
    shipping_method TEXT CHECK (shipping_method IN ('shipping', 'pickup')),
    shipping_address JSONB,
    square_payment_id TEXT,
    square_order_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create order_item table
CREATE TABLE IF NOT EXISTS potterbase.order_item (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES potterbase."order"(id) ON DELETE CASCADE,
    piece_id INTEGER NOT NULL REFERENCES potterbase.piece(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity > 0),
    price DECIMAL(10,2) NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_order_user_id ON potterbase."order"(user_id);
CREATE INDEX IF NOT EXISTS idx_order_status ON potterbase."order"(status);
CREATE INDEX IF NOT EXISTS idx_order_number ON potterbase."order"(order_number);
CREATE INDEX IF NOT EXISTS idx_order_item_order_id ON potterbase.order_item(order_id);
CREATE INDEX IF NOT EXISTS idx_order_item_piece_id ON potterbase.order_item(piece_id);

-- Add updated_at trigger for order table
CREATE OR REPLACE FUNCTION potterbase.update_order_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER order_updated_at
    BEFORE UPDATE ON potterbase."order"
    FOR EACH ROW
    EXECUTE FUNCTION potterbase.update_order_updated_at();

-- Function to generate order number
CREATE OR REPLACE FUNCTION potterbase.generate_order_number()
RETURNS TEXT AS $$
DECLARE
    new_order_number TEXT;
BEGIN
    LOOP
        new_order_number := 'ORD-' || TO_CHAR(now(), 'YYYYMMDD') || '-' || LPAD(FLOOR(RANDOM() * 10000)::TEXT, 4, '0');
        IF NOT EXISTS (SELECT 1 FROM potterbase."order" WHERE order_number = new_order_number) THEN
            RETURN new_order_number;
        END IF;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE potterbase."order" IS 'Customer orders for ecommerce';
COMMENT ON TABLE potterbase.order_item IS 'Order line items';

