-- Remove ecommerce fields from piece table
ALTER TABLE potterbase.piece DROP COLUMN IF EXISTS is_for_sale;
ALTER TABLE potterbase.piece DROP COLUMN IF EXISTS in_stock;
DROP INDEX IF EXISTS potterbase.idx_piece_is_for_sale;
DROP INDEX IF EXISTS potterbase.idx_piece_in_stock;

