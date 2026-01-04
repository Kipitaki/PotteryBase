-- Rollback: just drop the constraint
ALTER TABLE potterbase.piece_likes
DROP CONSTRAINT IF EXISTS fk_piece_likes_user_id;

