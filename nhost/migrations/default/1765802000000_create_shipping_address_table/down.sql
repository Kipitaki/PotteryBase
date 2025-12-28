-- Drop shipping_address table
DROP TABLE IF EXISTS potterbase.shipping_address CASCADE;
DROP FUNCTION IF EXISTS potterbase.ensure_single_default_address() CASCADE;
DROP FUNCTION IF EXISTS potterbase.update_shipping_address_updated_at() CASCADE;

