ALTER TABLE potterbase.piece_stage_history 
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
