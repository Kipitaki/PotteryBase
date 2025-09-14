-- Make sure pgcrypto is enabled
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Update email and set new password
UPDATE auth.users
SET 
  email = 'allyanne74@yahoo.com',
  password_hash = crypt('Kipitakithecat24', gen_salt('bf'))
WHERE email = 'old_fake_email@example.com';
