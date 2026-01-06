-- Add actual_postage_cost column to orders table
ALTER TABLE bandanas.orders
ADD COLUMN IF NOT EXISTS actual_postage_cost DECIMAL(10,2);

-- Add comment
COMMENT ON COLUMN bandanas.orders.actual_postage_cost IS 'Actual USPS postage cost paid (USD)';

