-- Rollback: Remove price column
ALTER TABLE potterbase.piece DROP COLUMN IF EXISTS price;
