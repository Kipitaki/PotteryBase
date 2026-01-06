-- Add original_address_id column to store external/Salesforce IDs for mapping
ALTER TABLE bandanas.buyer_addresses
ADD COLUMN IF NOT EXISTS original_address_id TEXT;

-- Add index for faster lookups when importing orders
CREATE INDEX IF NOT EXISTS idx_buyer_addresses_original_address_id ON bandanas.buyer_addresses(original_address_id);

-- Add comment
COMMENT ON COLUMN bandanas.buyer_addresses.original_address_id IS 'Stores the original address ID from external systems (e.g., Salesforce) for mapping purposes when importing related data';

