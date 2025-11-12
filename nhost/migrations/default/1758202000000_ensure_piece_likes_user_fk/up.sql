-- Ensure foreign key constraint exists on piece_likes.user_id
-- This constraint is created for data integrity, but relationships use manual_configuration

-- Create the foreign key constraint if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_constraint
        WHERE conrelid = 'potterbase.piece_likes'::regclass
          AND conname = 'fk_piece_likes_user_id'
          AND contype = 'f'
    ) THEN
        ALTER TABLE potterbase.piece_likes
        ADD CONSTRAINT fk_piece_likes_user_id
        FOREIGN KEY (user_id) 
        REFERENCES potterbase.profiles(id) 
        ON DELETE CASCADE;
    END IF;
END $$;

