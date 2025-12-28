-- Create shipping_address table
CREATE TABLE IF NOT EXISTS potterbase.shipping_address (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    street_address TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    zip_code TEXT NOT NULL,
    phone TEXT,
    is_default BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_shipping_address_user_id ON potterbase.shipping_address(user_id);
CREATE INDEX IF NOT EXISTS idx_shipping_address_user_default ON potterbase.shipping_address(user_id, is_default) WHERE is_default = true;

-- Ensure only one default address per user
CREATE OR REPLACE FUNCTION potterbase.ensure_single_default_address()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_default = true THEN
        UPDATE potterbase.shipping_address
        SET is_default = false
        WHERE user_id = NEW.user_id
        AND id != NEW.id
        AND is_default = true;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER shipping_address_single_default
    BEFORE INSERT OR UPDATE ON potterbase.shipping_address
    FOR EACH ROW
    EXECUTE FUNCTION potterbase.ensure_single_default_address();

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION potterbase.update_shipping_address_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER shipping_address_updated_at
    BEFORE UPDATE ON potterbase.shipping_address
    FOR EACH ROW
    EXECUTE FUNCTION potterbase.update_shipping_address_updated_at();

COMMENT ON TABLE potterbase.shipping_address IS 'Customer shipping addresses for orders';

