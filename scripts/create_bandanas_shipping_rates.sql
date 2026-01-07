-- Create shipping_rates table for quantity + zone based shipping costs
CREATE TABLE IF NOT EXISTS bandanas.shipping_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  zone INTEGER NOT NULL CHECK (zone >= 1 AND zone <= 9),
  cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(quantity, zone)
);

-- Add comments
COMMENT ON TABLE bandanas.shipping_rates IS 'Shipping rate estimates by quantity and zone';
COMMENT ON COLUMN bandanas.shipping_rates.quantity IS 'Order quantity (1, 2, 3, etc.)';
COMMENT ON COLUMN bandanas.shipping_rates.zone IS 'USPS zone (1-9)';
COMMENT ON COLUMN bandanas.shipping_rates.cost IS 'Shipping cost in USD';

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_shipping_rates_quantity_zone ON bandanas.shipping_rates(quantity, zone);

-- Drop trigger if it exists, then create trigger to update updated_at
DROP TRIGGER IF EXISTS shipping_rates_set_updated_at ON bandanas.shipping_rates;
CREATE TRIGGER shipping_rates_set_updated_at
BEFORE UPDATE ON bandanas.shipping_rates
FOR EACH ROW
EXECUTE FUNCTION bandanas.set_updated_at();

-- Grant permissions
GRANT ALL ON TABLE bandanas.shipping_rates TO postgres;

