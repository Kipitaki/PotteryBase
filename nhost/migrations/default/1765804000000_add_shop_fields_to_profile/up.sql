-- Add shop fields to profiles table for shareable shop pages
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'potterbase' 
        AND table_name = 'profiles' 
        AND column_name = 'shop_enabled'
    ) THEN
        ALTER TABLE potterbase.profiles ADD COLUMN shop_enabled BOOLEAN NOT NULL DEFAULT false;
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'potterbase' 
        AND table_name = 'profiles' 
        AND column_name = 'shop_slug'
    ) THEN
        ALTER TABLE potterbase.profiles ADD COLUMN shop_slug TEXT UNIQUE;
    END IF;

    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'potterbase' 
        AND table_name = 'profiles' 
        AND column_name = 'shop_name'
    ) THEN
        ALTER TABLE potterbase.profiles ADD COLUMN shop_name TEXT;
    END IF;
END $$;

-- Create index for shop slug lookups
CREATE INDEX IF NOT EXISTS idx_profiles_shop_slug ON potterbase.profiles(shop_slug) WHERE shop_slug IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_profiles_shop_enabled ON potterbase.profiles(shop_enabled) WHERE shop_enabled = true;

COMMENT ON COLUMN potterbase.profiles.shop_enabled IS 'Whether this user has enabled their shareable shop page';
COMMENT ON COLUMN potterbase.profiles.shop_slug IS 'URL-friendly identifier for the shop page (e.g., "allison-pottery")';
COMMENT ON COLUMN potterbase.profiles.shop_name IS 'Display name for the shop (e.g., "Allison''s Pottery Studio")';

