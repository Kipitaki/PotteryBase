-- Remove tracking_number column
ALTER TABLE bandanas.orders
DROP COLUMN IF EXISTS tracking_number;

-- Remove order_number column
ALTER TABLE bandanas.orders
DROP COLUMN IF EXISTS order_number;

-- Drop indexes
DROP INDEX IF EXISTS bandanas.idx_orders_tracking_number;
DROP INDEX IF EXISTS bandanas.idx_orders_order_number;

