-- Create the bandanas schema if it doesn't exist
CREATE SCHEMA IF NOT EXISTS bandanas;

-- Create the set_updated_at() function for the bandanas schema
CREATE OR REPLACE FUNCTION bandanas.set_updated_at()
RETURNS trigger AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create buyers table
CREATE TABLE bandanas.buyers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create trigger for updated_at
CREATE TRIGGER buyers_set_updated_at
BEFORE UPDATE ON bandanas.buyers
FOR EACH ROW
EXECUTE FUNCTION bandanas.set_updated_at();

-- Grant permissions
GRANT USAGE ON SCHEMA bandanas TO postgres;
GRANT ALL ON TABLE bandanas.buyers TO postgres;

