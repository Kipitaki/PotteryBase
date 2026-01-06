-- Remove the postage calculation fields from orders table
ALTER TABLE bandanas.orders
DROP COLUMN IF EXISTS estimated_postage_cost,
DROP COLUMN IF EXISTS weight,
DROP COLUMN IF EXISTS height,
DROP COLUMN IF EXISTS width,
DROP COLUMN IF EXISTS length;

