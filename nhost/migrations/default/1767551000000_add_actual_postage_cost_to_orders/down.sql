-- Remove the actual_postage_cost column from orders table
ALTER TABLE bandanas.orders
DROP COLUMN IF EXISTS actual_postage_cost;

