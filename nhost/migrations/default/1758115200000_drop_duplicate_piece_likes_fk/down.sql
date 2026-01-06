DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_piece_likes_user'
      AND conrelid = 'bandanas.piece_likes'::regclass
  ) THEN
    ALTER TABLE bandanas.piece_likes
      ADD CONSTRAINT fk_piece_likes_user
      FOREIGN KEY (user_id)
      REFERENCES bandanas.profiles(id)
      ON DELETE CASCADE;
  END IF;
END $$;

