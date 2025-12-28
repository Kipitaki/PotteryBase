-- Remove shop fields from profiles table
ALTER TABLE potterbase.profiles DROP COLUMN IF EXISTS shop_enabled;
ALTER TABLE potterbase.profiles DROP COLUMN IF EXISTS shop_slug;
ALTER TABLE potterbase.profiles DROP COLUMN IF EXISTS shop_name;
DROP INDEX IF EXISTS potterbase.idx_profiles_shop_slug;
DROP INDEX IF EXISTS potterbase.idx_profiles_shop_enabled;

