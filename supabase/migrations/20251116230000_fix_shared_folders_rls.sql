-- Fix RLS policies for shared_folders to allow admins to insert folders
-- The existing "Admins can manage folders" policy only has USING clause
-- For INSERT operations, we need WITH CHECK clause

-- Drop the existing policy
DROP POLICY IF EXISTS "Admins can manage folders" ON public.shared_folders;

-- Recreate with proper INSERT support
CREATE POLICY "Admins can manage folders"
  ON public.shared_folders FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.user_roles
      WHERE user_id = auth.uid() AND role = 'admin'
    )
  );

COMMENT ON POLICY "Admins can manage folders" ON public.shared_folders 
  IS 'Allows admin users to perform all operations (SELECT, INSERT, UPDATE, DELETE) on shared folders';
