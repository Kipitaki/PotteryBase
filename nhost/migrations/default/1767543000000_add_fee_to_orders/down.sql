-- Remove fee column
ALTER TABLE bandanas.orders
DROP COLUMN IF EXISTS fee;

