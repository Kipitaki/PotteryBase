-- Revert: Subtract $1.00 from all shipping rates
UPDATE potterbase.shipping_rates
SET cost = cost - 1.00;

