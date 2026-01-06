-- Remove the new fields from events table
ALTER TABLE bandanas.events
DROP COLUMN IF EXISTS bandana_cost,
DROP COLUMN IF EXISTS freight,
DROP COLUMN IF EXISTS fee_tax_transaction_fees,
DROP COLUMN IF EXISTS total_qty;

