-- Ensure foreign key constraint exists on piece_likes.user_id
-- This constraint is required for Hasura relationships to work

-- Drop any existing foreign key constraints on user_id to avoid duplicates
DO $$
DECLARE
    constraint_name text;
BEGIN
    -- Find all foreign key constraints on user_id column
    FOR constraint_name IN
        SELECT conname
        FROM pg_constraint
        WHERE conrelid = 'potterbase.piece_likes'::regclass
          AND contype = 'f'
          AND conkey::int[] <@ ARRAY[
              (SELECT attnum FROM pg_attribute 
               WHERE attrelid = 'potterbase.piece_likes'::regclass 
               AND attname = 'user_id')
          ]
    LOOP
        EXECUTE format('ALTER TABLE potterbase.piece_likes DROP CONSTRAINT IF EXISTS %I', constraint_name);
    END LOOP;
END $$;

-- Create the foreign key constraint with a standard name
ALTER TABLE potterbase.piece_likes
ADD CONSTRAINT fk_piece_likes_user_id
FOREIGN KEY (user_id) 
REFERENCES potterbase.profiles(id) 
ON DELETE CASCADE;

