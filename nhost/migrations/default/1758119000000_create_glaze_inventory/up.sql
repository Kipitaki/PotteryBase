CREATE TABLE potterbase.profile_glaze (
  id SERIAL PRIMARY KEY,
  profile_id UUID NOT NULL REFERENCES potterbase.profiles(id) ON DELETE CASCADE,
  glaze_id INTEGER NOT NULL REFERENCES potterbase.glaze(id) ON DELETE CASCADE,
  quantity NUMERIC,
  unit TEXT,
  location TEXT,
  status TEXT DEFAULT 'available',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (profile_id, glaze_id)
);

CREATE TABLE potterbase.class_glaze (
  id SERIAL PRIMARY KEY,
  glaze_id INTEGER NOT NULL REFERENCES potterbase.glaze(id) ON DELETE CASCADE,
  quantity NUMERIC,
  unit TEXT,
  location TEXT,
  status TEXT DEFAULT 'available',
  notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (glaze_id)
);

CREATE TRIGGER set_profile_glaze_updated_at
BEFORE UPDATE ON potterbase.profile_glaze
FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();

CREATE TRIGGER set_class_glaze_updated_at
BEFORE UPDATE ON potterbase.class_glaze
FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();

