-- Comprehensive RLS Fix for Documents and Diagrams
-- This migration resolves all row level security violations by:
-- 1. Cleaning up all duplicate and conflicting policies
-- 2. Recreating clean, consistent policies for all tables and buckets
-- 3. Ensuring bucket configurations are correct

-- ============================================================================
-- STEP 1: Clean up all existing policies on storage.objects
-- ============================================================================

-- Drop all document-related storage policies (including duplicates from different migrations)
DROP POLICY IF EXISTS "Authenticated users can upload documents" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload documents to storage" ON storage.objects;
DROP POLICY IF EXISTS "Public users can view documents in storage" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update documents in storage" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete documents from storage" ON storage.objects;

-- Drop all diagram-related storage policies
DROP POLICY IF EXISTS "Authenticated users can upload diagrams" ON storage.objects;
DROP POLICY IF EXISTS "Public users can view diagrams" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update diagrams" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete diagrams" ON storage.objects;

-- ============================================================================
-- STEP 2: Clean up all existing policies on public.documents table
-- ============================================================================

DROP POLICY IF EXISTS "Authenticated users can view all documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can upload documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can create documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can insert documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can update documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can delete documents" ON public.documents;

-- ============================================================================
-- STEP 2b: Clean up all existing policies on public.import_jobs table
-- ============================================================================

DROP POLICY IF EXISTS "Authenticated users can view all import jobs" ON public.import_jobs;
DROP POLICY IF EXISTS "Authenticated users can create import jobs" ON public.import_jobs;
DROP POLICY IF EXISTS "Authenticated users can insert import jobs" ON public.import_jobs;
DROP POLICY IF EXISTS "Authenticated users can update import jobs" ON public.import_jobs;
DROP POLICY IF EXISTS "Authenticated users can delete import jobs" ON public.import_jobs;

-- ============================================================================
-- STEP 3: Ensure RLS is enabled on all tables
-- ============================================================================

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.import_jobs ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- STEP 4: Create clean storage policies for DOCUMENTS bucket
-- ============================================================================

-- Allow authenticated users to INSERT files into documents bucket
CREATE POLICY "documents_storage_insert"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'documents');

-- Allow public users to SELECT/view files from documents bucket
CREATE POLICY "documents_storage_select"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'documents');

-- Allow authenticated users to UPDATE files in documents bucket
CREATE POLICY "documents_storage_update"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'documents')
  WITH CHECK (bucket_id = 'documents');

-- Allow authenticated users to DELETE files from documents bucket
CREATE POLICY "documents_storage_delete"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'documents');

-- ============================================================================
-- STEP 5: Create clean storage policies for DIAGRAMS bucket
-- ============================================================================

-- Allow authenticated users to INSERT files into diagrams bucket
CREATE POLICY "diagrams_storage_insert"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'diagrams');

-- Allow public users to SELECT/view files from diagrams bucket
CREATE POLICY "diagrams_storage_select"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'diagrams');

-- Allow authenticated users to UPDATE files in diagrams bucket
CREATE POLICY "diagrams_storage_update"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'diagrams')
  WITH CHECK (bucket_id = 'diagrams');

-- Allow authenticated users to DELETE files from diagrams bucket
CREATE POLICY "diagrams_storage_delete"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'diagrams');

-- ============================================================================
-- STEP 6: Create clean table policies for public.documents
-- ============================================================================

-- Allow authenticated users to SELECT all documents
CREATE POLICY "documents_table_select"
  ON public.documents FOR SELECT
  TO authenticated
  USING (true);

-- Allow authenticated users to INSERT documents
CREATE POLICY "documents_table_insert"
  ON public.documents FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Allow authenticated users to UPDATE documents
CREATE POLICY "documents_table_update"
  ON public.documents FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Allow authenticated users to DELETE documents
CREATE POLICY "documents_table_delete"
  ON public.documents FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- STEP 6b: Create clean table policies for public.import_jobs (if table exists)
-- ============================================================================

-- Only create policies if the table exists
DO $$
BEGIN
  IF EXISTS (
    SELECT FROM pg_tables
    WHERE schemaname = 'public'
    AND tablename = 'import_jobs'
  ) THEN
    -- Drop existing policies first
    DROP POLICY IF EXISTS "import_jobs_table_select" ON public.import_jobs;
    DROP POLICY IF EXISTS "import_jobs_table_insert" ON public.import_jobs;
    DROP POLICY IF EXISTS "import_jobs_table_update" ON public.import_jobs;
    DROP POLICY IF EXISTS "import_jobs_table_delete" ON public.import_jobs;
    
    -- Allow authenticated users to SELECT all import jobs
    EXECUTE 'CREATE POLICY "import_jobs_table_select" ON public.import_jobs FOR SELECT TO authenticated USING (true)';
    
    -- Allow authenticated users to INSERT import jobs
    EXECUTE 'CREATE POLICY "import_jobs_table_insert" ON public.import_jobs FOR INSERT TO authenticated WITH CHECK (true)';
    
    -- Allow authenticated users to UPDATE import jobs
    EXECUTE 'CREATE POLICY "import_jobs_table_update" ON public.import_jobs FOR UPDATE TO authenticated USING (true) WITH CHECK (true)';
    
    -- Allow authenticated users to DELETE import jobs
    EXECUTE 'CREATE POLICY "import_jobs_table_delete" ON public.import_jobs FOR DELETE TO authenticated USING (true)';
  END IF;
END $$;

-- ============================================================================
-- STEP 7: Ensure buckets are properly configured
-- ============================================================================

-- Make sure documents bucket exists and is public
UPDATE storage.buckets
SET public = true
WHERE id = 'documents';

-- Make sure diagrams bucket exists and is public
UPDATE storage.buckets
SET public = true
WHERE id = 'diagrams';

-- ============================================================================
-- Migration complete
-- ============================================================================
-- This migration should resolve all RLS violations by ensuring:
-- 1. No duplicate or conflicting policies
-- 2. Clear, consistent naming convention for all policies
-- 3. Proper bucket configurations
-- 4. All necessary operations are allowed for authenticated users
