-- Drop tables in reverse order of creation (to respect foreign key constraints)
DROP TABLE IF EXISTS bandanas.orders;
DROP TABLE IF EXISTS bandanas.events;
DROP TABLE IF EXISTS bandanas.buyer_addresses;
DROP TABLE IF EXISTS bandanas.buyers;

-- Drop the set_updated_at() function
DROP FUNCTION IF EXISTS bandanas.set_updated_at();

-- Drop the schema
DROP SCHEMA IF EXISTS bandanas;

