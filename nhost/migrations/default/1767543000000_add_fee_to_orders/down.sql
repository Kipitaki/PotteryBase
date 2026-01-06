-- Remove fee column
ALTER TABLE potterbase.orders
DROP COLUMN IF EXISTS fee;

