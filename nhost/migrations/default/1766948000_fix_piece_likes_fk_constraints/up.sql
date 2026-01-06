-- Fix duplicate foreign key constraints on piece_likes.user_id
-- Drop all existing constraints and create a single one

DO $$
DECLARE
    constraint_name TEXT;
BEGIN
    -- Drop all foreign key constraints on user_id column
    FOR constraint_name IN 
        SELECT conname 
        FROM pg_constraint 
        WHERE conrelid = 'bandanas.piece_likes'::regclass 
          AND contype = 'f'
          AND conkey::text LIKE '%user_id%'
    LOOP
        EXECUTE format('ALTER TABLE bandanas.piece_likes DROP CONSTRAINT IF EXISTS %I', constraint_name);
    END LOOP;
    
    -- Create a single, clean foreign key constraint
    ALTER TABLE bandanas.piece_likes
    ADD CONSTRAINT fk_piece_likes_user_id
    FOREIGN KEY (user_id) 
    REFERENCES bandanas.profiles(id) 
    ON DELETE CASCADE;
END $$;

