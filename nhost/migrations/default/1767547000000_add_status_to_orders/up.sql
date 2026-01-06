-- Add status column to orders table
ALTER TABLE bandanas.orders
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'Ordered' 
  CHECK (status IN ('Ordered', 'Shipped', 'Received', 'Other'));

-- Add comment
COMMENT ON COLUMN bandanas.orders.status IS 'Order status: Ordered, Shipped, Received, or Other';

