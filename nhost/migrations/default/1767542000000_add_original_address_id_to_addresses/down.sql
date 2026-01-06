-- Remove index
DROP INDEX IF EXISTS bandanas.idx_buyer_addresses_original_address_id;

-- Remove column
ALTER TABLE bandanas.buyer_addresses
DROP COLUMN IF EXISTS original_address_id;

