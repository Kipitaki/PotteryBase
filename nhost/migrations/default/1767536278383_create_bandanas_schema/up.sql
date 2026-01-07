-- Create the bandanas schema
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

CREATE TRIGGER buyers_set_updated_at
BEFORE UPDATE ON bandanas.buyers
FOR EACH ROW
EXECUTE FUNCTION bandanas.set_updated_at();

-- Create buyer_addresses table
CREATE TABLE bandanas.buyer_addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id UUID NOT NULL
    REFERENCES bandanas.buyers(id)
    ON DELETE CASCADE,
  address_line1 TEXT NOT NULL,
  address_line2 TEXT,
  city TEXT NOT NULL,
  state TEXT,
  postal_code TEXT NOT NULL,
  country TEXT NOT NULL DEFAULT 'US',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER buyer_addresses_set_updated_at
BEFORE UPDATE ON bandanas.buyer_addresses
FOR EACH ROW
EXECUTE FUNCTION bandanas.set_updated_at();

-- Create events table
CREATE TABLE bandanas.events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  year INTEGER NOT NULL,
  price_single DECIMAL(18,2) NOT NULL CHECK (price_single >= 0),
  price_multi DECIMAL(18,2) NOT NULL CHECK (price_multi >= 0),
  active BOOLEAN NOT NULL DEFAULT TRUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER events_set_updated_at
BEFORE UPDATE ON bandanas.events
FOR EACH ROW
EXECUTE FUNCTION bandanas.set_updated_at();

-- Create orders table
CREATE TABLE bandanas.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  buyer_id UUID NOT NULL
    REFERENCES bandanas.buyers(id)
    ON DELETE RESTRICT,
  address_id UUID
    REFERENCES bandanas.buyer_addresses(id)
    ON DELETE SET NULL,
  event_id UUID NOT NULL
    REFERENCES bandanas.events(id)
    ON DELETE RESTRICT,
  order_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  total_price DECIMAL(18,2) NOT NULL CHECK (total_price >= 0),
  amount_paid DECIMAL(18,2) NOT NULL CHECK (amount_paid >= 0),
  payment_method TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER orders_set_updated_at
BEFORE UPDATE ON bandanas.orders
FOR EACH ROW
EXECUTE FUNCTION bandanas.set_updated_at();

