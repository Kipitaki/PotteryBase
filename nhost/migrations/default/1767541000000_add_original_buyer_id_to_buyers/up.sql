-- Add original_buyer_id column to store external/Salesforce IDs for mapping
ALTER TABLE potterbase.buyers
ADD COLUMN IF NOT EXISTS original_buyer_id TEXT;

-- Add index for faster lookups when importing addresses/orders
CREATE INDEX IF NOT EXISTS idx_buyers_original_buyer_id ON potterbase.buyers(original_buyer_id);

-- Add comment
COMMENT ON COLUMN potterbase.buyers.original_buyer_id IS 'Stores the original buyer ID from external systems (e.g., Salesforce) for mapping purposes when importing related data';

