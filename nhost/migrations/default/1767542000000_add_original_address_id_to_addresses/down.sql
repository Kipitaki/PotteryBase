-- Remove index
DROP INDEX IF EXISTS potterbase.idx_buyer_addresses_original_address_id;

-- Remove column
ALTER TABLE potterbase.buyer_addresses
DROP COLUMN IF EXISTS original_address_id;

