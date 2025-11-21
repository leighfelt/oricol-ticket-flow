-- Create schema_migrations table to track applied migrations
CREATE TABLE IF NOT EXISTS public.schema_migrations (
  version text PRIMARY KEY,
  applied_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.schema_migrations ENABLE ROW LEVEL SECURITY;

-- Allow admins to view migration status
CREATE POLICY "Admins can view schema_migrations" 
ON public.schema_migrations 
FOR SELECT 
USING (public.has_role(auth.uid(), 'admin'));

-- Allow the apply-migrations edge function to insert migration records
-- This policy allows authenticated users to insert, but the edge function
-- will handle the actual authorization
CREATE POLICY "Authenticated users can insert schema_migrations" 
ON public.schema_migrations 
FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);