-- Rollback: Remove price column
ALTER TABLE bandanas.piece DROP COLUMN IF EXISTS price;
