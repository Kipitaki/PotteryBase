-- Remove index
DROP INDEX IF EXISTS potterbase.idx_buyers_original_buyer_id;

-- Remove column
ALTER TABLE potterbase.buyers
DROP COLUMN IF EXISTS original_buyer_id;

