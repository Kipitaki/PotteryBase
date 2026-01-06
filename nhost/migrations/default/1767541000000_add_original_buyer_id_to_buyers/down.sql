-- Remove index
DROP INDEX IF EXISTS bandanas.idx_buyers_original_buyer_id;

-- Remove column
ALTER TABLE bandanas.buyers
DROP COLUMN IF EXISTS original_buyer_id;

