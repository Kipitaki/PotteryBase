-- Create shipping_rates table for custom postage cost estimates
CREATE TABLE IF NOT EXISTS bandanas.shipping_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  zone INTEGER NOT NULL CHECK (zone >= 1 AND zone <= 9),
  weight_min DECIMAL(10,2) NOT NULL CHECK (weight_min >= 0),
  weight_max DECIMAL(10,2) NOT NULL CHECK (weight_max > weight_min),
  cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(zone, weight_min, weight_max)
);

-- Add comment
COMMENT ON TABLE bandanas.shipping_rates IS 'Custom shipping rate estimates by zone and weight range';
COMMENT ON COLUMN bandanas.shipping_rates.zone IS 'USPS zone (1-9)';
COMMENT ON COLUMN bandanas.shipping_rates.weight_min IS 'Minimum weight in ounces (inclusive)';
COMMENT ON COLUMN bandanas.shipping_rates.weight_max IS 'Maximum weight in ounces (exclusive)';
COMMENT ON COLUMN bandanas.shipping_rates.cost IS 'Shipping cost in USD';

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_shipping_rates_zone_weight ON bandanas.shipping_rates(zone, weight_min, weight_max);

-- Create trigger to update updated_at
CREATE TRIGGER shipping_rates_set_updated_at
BEFORE UPDATE ON bandanas.shipping_rates
FOR EACH ROW
EXECUTE FUNCTION bandanas.set_updated_at();

