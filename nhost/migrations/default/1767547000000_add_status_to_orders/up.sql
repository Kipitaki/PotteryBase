-- Add status column to orders table
ALTER TABLE potterbase.orders
ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'Ordered' 
  CHECK (status IN ('Ordered', 'Shipped', 'Received', 'Other'));

-- Add comment
COMMENT ON COLUMN potterbase.orders.status IS 'Order status: Ordered, Shipped, Received, or Other';

