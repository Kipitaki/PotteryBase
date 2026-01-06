-- Remove the status column from orders table
ALTER TABLE potterbase.orders
DROP COLUMN IF EXISTS status;

