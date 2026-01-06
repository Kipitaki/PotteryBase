-- Drop tables in reverse order of creation (to respect foreign key constraints)
DROP TABLE IF EXISTS potterbase.orders;
DROP TABLE IF EXISTS potterbase.events;
DROP TABLE IF EXISTS potterbase.buyer_addresses;
DROP TABLE IF EXISTS potterbase.buyers;

-- Drop the set_updated_at() function
DROP FUNCTION IF EXISTS potterbase.set_updated_at();

-- Drop the schema
DROP SCHEMA IF EXISTS bandanas;

