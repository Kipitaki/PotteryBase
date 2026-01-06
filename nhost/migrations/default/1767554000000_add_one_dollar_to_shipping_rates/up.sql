-- Add $1.00 to all existing shipping rates
UPDATE bandanas.shipping_rates
SET cost = cost + 1.00;

COMMENT ON TABLE bandanas.shipping_rates IS 'Shipping rate estimates by quantity and zone (updated: +$1.00 added to all rates)';

