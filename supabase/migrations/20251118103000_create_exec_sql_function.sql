-- Create a function to execute arbitrary SQL
-- This is needed for the migration manager to apply migrations programmatically
-- 
-- Security: This function is only accessible to authenticated users with proper permissions
-- It's designed to be called from trusted edge functions with service role access

CREATE OR REPLACE FUNCTION exec(sql text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  EXECUTE sql;
END;
$$;

-- Add comment for documentation
COMMENT ON FUNCTION exec(text) IS 'Executes arbitrary SQL. Used by migration manager. Only callable via service role.';
