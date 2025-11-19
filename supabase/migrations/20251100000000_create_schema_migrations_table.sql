-- Create the schema_migrations table to track which migrations have been applied
-- This table is used by the migration system to know which migrations are pending
-- 
-- NOTE: This migration should be run FIRST before all other migrations
-- The table name 'schema_migrations' is a standard convention used by many migration systems

CREATE TABLE IF NOT EXISTS public.schema_migrations (
  version text PRIMARY KEY,
  applied_at timestamptz DEFAULT now() NOT NULL
);

-- Add a comment to document the table's purpose
COMMENT ON TABLE public.schema_migrations IS 'Tracks which database migrations have been applied. Used by the migration management system.';
COMMENT ON COLUMN public.schema_migrations.version IS 'The migration version/filename (without .sql extension)';
COMMENT ON COLUMN public.schema_migrations.applied_at IS 'Timestamp when the migration was applied';

-- Enable RLS on this table (optional, but good practice)
ALTER TABLE public.schema_migrations ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to read the migration status
-- This is needed for the migration manager UI to show which migrations are applied
CREATE POLICY "Allow authenticated users to view migrations"
  ON public.schema_migrations FOR SELECT
  TO authenticated
  USING (true);

-- Only allow service role to insert/update/delete migration records
-- This prevents regular users from manipulating the migration history
CREATE POLICY "Only service role can modify migrations"
  ON public.schema_migrations FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
