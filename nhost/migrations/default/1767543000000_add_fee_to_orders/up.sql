-- Add fee column to orders table
ALTER TABLE potterbase.orders
ADD COLUMN IF NOT EXISTS fee DECIMAL(18,2) CHECK (fee >= 0);

-- Add comment
COMMENT ON COLUMN potterbase.orders.fee IS 'Additional fee charged on the order';

