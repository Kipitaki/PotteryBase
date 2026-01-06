-- Add order_number and tracking_number columns to orders table
ALTER TABLE potterbase.orders
ADD COLUMN IF NOT EXISTS order_number TEXT UNIQUE;

-- Create index for faster lookups by order number
CREATE INDEX IF NOT EXISTS idx_orders_order_number ON potterbase.orders(order_number);

-- Add tracking_number column
ALTER TABLE potterbase.orders
ADD COLUMN IF NOT EXISTS tracking_number TEXT;

-- Create index for tracking number lookups
CREATE INDEX IF NOT EXISTS idx_orders_tracking_number ON potterbase.orders(tracking_number);

COMMENT ON COLUMN potterbase.orders.order_number IS 'Unique order number for matching during import/export';
COMMENT ON COLUMN potterbase.orders.tracking_number IS 'Shipping tracking number';

