-- Remove the status column from orders table
ALTER TABLE bandanas.orders
DROP COLUMN IF EXISTS status;

