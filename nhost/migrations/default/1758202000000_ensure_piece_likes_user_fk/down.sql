-- Rollback: Drop the foreign key constraint
ALTER TABLE bandanas.piece_likes
DROP CONSTRAINT IF EXISTS fk_piece_likes_user_id;

