-- Add postage calculation fields to orders table
ALTER TABLE potterbase.orders
ADD COLUMN IF NOT EXISTS length DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS width DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS height DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS weight DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS estimated_postage_cost DECIMAL(10,2);

-- Add comments
COMMENT ON COLUMN potterbase.orders.length IS 'Package length in inches';
COMMENT ON COLUMN potterbase.orders.width IS 'Package width in inches';
COMMENT ON COLUMN potterbase.orders.height IS 'Package height in inches';
COMMENT ON COLUMN potterbase.orders.weight IS 'Package weight in ounces';
COMMENT ON COLUMN potterbase.orders.estimated_postage_cost IS 'Estimated USPS postage cost in USD';

