-- Enable RLS on storage.objects
ALTER TABLE IF EXISTS storage.objects ENABLE ROW LEVEL SECURITY;

-- Allow service_role full access
CREATE POLICY IF NOT EXISTS "storage_service_role_full" ON storage.objects
  FOR ALL
  USING ( auth.role() = 'service_role' )
  WITH CHECK ( auth.role() = 'service_role' );

-- Allow authenticated users to SELECT their own objects (assumes metadata->>'owner' is set at upload time)
CREATE POLICY IF NOT EXISTS "storage_select_owner" ON storage.objects
  FOR SELECT
  USING (
    auth.role() = 'service_role' OR
    (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

-- Allow authenticated users to INSERT objects only if metadata.owner == auth.uid()
CREATE POLICY IF NOT EXISTS "storage_insert_owner" ON storage.objects
  FOR INSERT
  WITH CHECK (
    auth.role() = 'service_role' OR
    (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

-- Allow updates/deletes only by owner or service_role
CREATE POLICY IF NOT EXISTS "storage_update_owner" ON storage.objects
  FOR UPDATE
  USING (
    auth.role() = 'service_role' OR
    (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  )
  WITH CHECK (
    auth.role() = 'service_role' OR
    (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );

CREATE POLICY IF NOT EXISTS "storage_delete_owner" ON storage.objects
  FOR DELETE
  USING (
    auth.role() = 'service_role' OR
    (auth.role() = 'authenticated' AND (metadata->> 'owner') = auth.uid())
  );
