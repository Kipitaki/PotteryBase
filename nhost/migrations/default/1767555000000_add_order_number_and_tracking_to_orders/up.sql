-- Add order_number and tracking_number columns to orders table
ALTER TABLE bandanas.orders
ADD COLUMN IF NOT EXISTS order_number TEXT UNIQUE;

-- Create index for faster lookups by order number
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON bandanas.orders(order_number);

-- Add tracking_number column
ALTER TABLE bandanas.orders
ADD COLUMN IF NOT EXISTS tracking_number TEXT;

-- Create index for tracking number lookups
CREATE INDEX IF NOT EXISTS idx_orders_tracking_number ON bandanas.orders(tracking_number);

COMMENT ON COLUMN bandanas.orders.order_number IS 'Unique order number for matching during import/export';
COMMENT ON COLUMN bandanas.orders.tracking_number IS 'Shipping tracking number';

