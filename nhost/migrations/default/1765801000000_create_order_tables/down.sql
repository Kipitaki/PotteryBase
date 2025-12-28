-- Drop order tables
DROP TABLE IF EXISTS potterbase.order_item CASCADE;
DROP TABLE IF EXISTS potterbase."order" CASCADE;
DROP FUNCTION IF EXISTS potterbase.update_order_updated_at() CASCADE;
DROP FUNCTION IF EXISTS potterbase.generate_order_number() CASCADE;

