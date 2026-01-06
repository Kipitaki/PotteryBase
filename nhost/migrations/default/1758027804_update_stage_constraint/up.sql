-- Update the stage_valid constraint to include new stage names
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
    'archived'::text, 
    'failed'::text
  ])
);
