-- Add fee column to orders table
ALTER TABLE bandanas.orders
ADD COLUMN IF NOT EXISTS fee DECIMAL(18,2) CHECK (fee >= 0);

-- Add comment
COMMENT ON COLUMN bandanas.orders.fee IS 'Additional fee charged on the order';

