-- make sure pgcrypto is enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- reset password
UPDATE auth.users
SET password_hash = crypt('Kipitakithecat24', gen_salt('bf'))
WHERE id = '005202a4-fd35-4761-8a91-4faf0f6b1009';
