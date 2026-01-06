-- Revert to weight-based structure (not really reversible, but kept for migration consistency)
DROP TABLE IF EXISTS bandanas.shipping_rates;

CREATE TABLE bandanas.shipping_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  zone INTEGER NOT NULL CHECK (zone >= 1 AND zone <= 9),
  weight_min DECIMAL(10,2) NOT NULL CHECK (weight_min >= 0),
  weight_max DECIMAL(10,2) NOT NULL CHECK (weight_max > weight_min),
  cost DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(zone, weight_min, weight_max)
);

