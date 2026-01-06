-- Remove the usps_zone column from orders table
ALTER TABLE bandanas.orders
DROP COLUMN IF EXISTS usps_zone;

