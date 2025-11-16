-- Lovable combined storage policies
-- Paste into Supabase SQL editor and run as a privileged user (project admin / service_role)
-- Notes:
-- 1) These policies require uploads to include metadata->>'owner' equal to the Supabase user id (auth.uid()).
-- 2) If you do NOT want documents/diagrams to be public-read, remove the documents_public_select / diagrams_public_select blocks below.
-- 3) After applying these policies, rotate the service_role key and deploy any server-side components that need the new key.

-- =================================================================
-- 1) Enable RLS on storage.objects
-- =================================================================
ALTER TABLE IF EXISTS storage.objects ENABLE ROW LEVEL SECURITY;

-- =================================================================
-- 2) Service role full-access policy (server-side processes)
-- =================================================================
CREATE POLICY IF NOT EXISTS storage_service_role_full
  ON storage.objects
  FOR ALL
  USING ( auth.role() = 'service_role' )
  WITH CHECK ( auth.role() = 'service_role' );

-- =================================================================
-- 3) Generic owner-based policies for all buckets
--    - SELECT: owners can read their objects; service_role can read all
--    - INSERT: authenticated users must set metadata->>'owner' = auth.uid()
--    - UPDATE/DELETE: only owner or service_role
-- =================================================================
CREATE POLICY IF NOT EXISTS storage_select_owner
  ON storage.objects
  FOR SELECT
  USING (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

CREATE POLICY IF NOT EXISTS storage_insert_owner
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

CREATE POLICY IF NOT EXISTS storage_update_owner
  ON storage.objects
  FOR UPDATE
  USING (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  )
  WITH CHECK (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

CREATE POLICY IF NOT EXISTS storage_delete_owner
  ON storage.objects
  FOR DELETE
  USING (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

-- =================================================================
-- 4) Per-bucket exceptions / convenience policies
--    Make documents and diagrams publicly readable (optional)
--    If you prefer owner-only read for these, remove these policies
-- =================================================================
CREATE POLICY IF NOT EXISTS documents_public_select
  ON storage.objects
  FOR SELECT
  USING ( bucket_id = 'documents' );

CREATE POLICY IF NOT EXISTS diagrams_public_select
  ON storage.objects
  FOR SELECT
  USING ( bucket_id = 'diagrams' );

-- =================================================================
-- 5) Explicit owner-only policies for 'branches' bucket (insert/update/delete)
-- =================================================================
CREATE POLICY IF NOT EXISTS branches_storage_insert
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

CREATE POLICY IF NOT EXISTS branches_storage_update
  ON storage.objects
  FOR UPDATE
  USING (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  )
  WITH CHECK (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

CREATE POLICY IF NOT EXISTS branches_storage_delete
  ON storage.objects
  FOR DELETE
  USING (
    auth.role() = 'service_role'
    OR (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

-- =================================================================
-- 6) Diagnostic queries (run separately to inspect)
-- =================================================================
-- Check whether RLS is enabled for storage.objects
-- SELECT relname, relrowsecurity FROM pg_class WHERE relname='objects';

-- List existing policies for storage.objects
-- SELECT policyname, permissive, roles, qual, with_check FROM pg_policies WHERE schemaname='storage' AND tablename='objects';

-- Inspect recent objects' metadata and owners
-- SELECT id, name, bucket_id, metadata->>'owner' AS owner, metadata, created_at
-- FROM storage.objects
-- ORDER BY created_at DESC
-- LIMIT 50;

-- =================================================================
-- 7) Temporary debug policy (ONLY use briefly for debug; remove after testing)
--    Use this if you need to confirm that the RLS policy is blocking INSERTs.
-- =================================================================
-- CREATE POLICY IF NOT EXISTS temp_allow_auth_inserts ON storage.objects
--   FOR INSERT
--   USING ( auth.role() = 'service_role' OR auth.role() = 'authenticated' )
--   WITH CHECK ( true );

-- After testing, remove:
-- DROP POLICY IF EXISTS temp_allow_auth_inserts ON storage.objects;

-- =================================================================
-- End of file
-- =================================================================