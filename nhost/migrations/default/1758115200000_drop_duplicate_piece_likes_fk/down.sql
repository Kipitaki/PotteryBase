DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'fk_piece_likes_user'
      AND conrelid = 'potterbase.piece_likes'::regclass
  ) THEN
    ALTER TABLE potterbase.piece_likes
      ADD CONSTRAINT fk_piece_likes_user
      FOREIGN KEY (user_id)
      REFERENCES potterbase.profiles(id)
      ON DELETE CASCADE;
  END IF;
END $$;

