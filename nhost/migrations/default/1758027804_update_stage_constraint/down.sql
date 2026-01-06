-- Revert the stage_valid constraint to original stage names
ALTER TABLE bandanas.piece_stage_history 
DROP CONSTRAINT stage_valid;

ALTER TABLE bandanas.piece_stage_history 
ADD CONSTRAINT stage_valid CHECK (
  stage = ANY (ARRAY[
    'lump'::text, 
    'formed'::text, 
    'trimmed'::text, 
    'bisque'::text, 
    'glazed'::text, 
    'fired'::text, 
    'sold_posted'::text, 
    'sold_kept'::text
  ])
);
