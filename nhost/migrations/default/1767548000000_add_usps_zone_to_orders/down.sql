-- Remove the usps_zone column from orders table
ALTER TABLE potterbase.orders
DROP COLUMN IF EXISTS usps_zone;

