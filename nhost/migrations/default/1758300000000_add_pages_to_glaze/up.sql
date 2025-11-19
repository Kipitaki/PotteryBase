-- Add pages column to potterbase.glaze table (idempotent)
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'potterbase' 
        AND table_name = 'glaze' 
        AND column_name = 'pages'
    ) THEN
        ALTER TABLE potterbase.glaze ADD COLUMN pages TEXT;
    END IF;
END $$;


