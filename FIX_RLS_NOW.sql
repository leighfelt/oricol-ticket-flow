-- ============================================================================
-- CONSOLIDATED FIX FOR ROW LEVEL SECURITY VIOLATIONS
-- ============================================================================
-- This script fixes all "new row violates row-level security" errors
-- for document and image uploads in the Oricol Helpdesk App.
--
-- APPLY THIS IN YOUR SUPABASE SQL EDITOR
-- 
-- Instructions:
-- 1. Go to https://supabase.com/dashboard
-- 2. Select your project
-- 3. Click "SQL Editor" in the sidebar
-- 4. Click "New Query"
-- 5. Copy this ENTIRE file
-- 6. Paste into the editor
-- 7. Click "Run" (or press F5)
-- 8. Wait for "Success" message
-- 9. Test document/image upload - it should work!
-- ============================================================================

-- ============================================================================
-- PART 1: CREATE STORAGE BUCKETS (if they don't exist)
-- ============================================================================

-- Create 'documents' bucket for document uploads
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'documents',
  'documents',
  true, -- Public bucket for easy viewing
  104857600, -- 100MB limit
  ARRAY[
    'application/pdf',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document', -- .docx
    'application/msword', -- .doc
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', -- .xlsx
    'application/vnd.ms-excel', -- .xls
    'application/vnd.openxmlformats-officedocument.presentationml.presentation', -- .pptx
    'application/vnd.ms-powerpoint', -- .ppt
    'text/plain',
    'text/csv',
    'application/zip',
    'application/x-zip-compressed',
    'image/png',
    'image/jpeg',
    'image/jpg',
    'image/gif',
    'image/webp'
  ]
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- Create 'diagrams' bucket for image uploads
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'diagrams',
  'diagrams',
  true, -- Public bucket for easy viewing
  52428800, -- 50MB limit
  ARRAY['image/png', 'image/jpeg', 'image/jpg', 'image/webp', 'image/gif']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

-- ============================================================================
-- PART 2: ENABLE ROW LEVEL SECURITY
-- ============================================================================

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.documents ENABLE ROW LEVEL SECURITY;

-- ============================================================================
-- PART 3: CLEAN UP ALL EXISTING POLICIES (to avoid conflicts)
-- ============================================================================

-- Drop all document-related storage policies
DROP POLICY IF EXISTS "Authenticated users can upload documents" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can upload documents to storage" ON storage.objects;
DROP POLICY IF EXISTS "Public users can view documents in storage" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update documents in storage" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete documents from storage" ON storage.objects;
DROP POLICY IF EXISTS "documents_storage_insert" ON storage.objects;
DROP POLICY IF EXISTS "documents_storage_select" ON storage.objects;
DROP POLICY IF EXISTS "documents_storage_update" ON storage.objects;
DROP POLICY IF EXISTS "documents_storage_delete" ON storage.objects;

-- Drop all diagram-related storage policies
DROP POLICY IF EXISTS "Authenticated users can upload diagrams" ON storage.objects;
DROP POLICY IF EXISTS "Public users can view diagrams" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update diagrams" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete diagrams" ON storage.objects;
DROP POLICY IF EXISTS "diagrams_storage_insert" ON storage.objects;
DROP POLICY IF EXISTS "diagrams_storage_select" ON storage.objects;
DROP POLICY IF EXISTS "diagrams_storage_update" ON storage.objects;
DROP POLICY IF EXISTS "diagrams_storage_delete" ON storage.objects;

-- ============================================================================
-- PART 4: CREATE CLEAN STORAGE POLICIES FOR DOCUMENTS BUCKET
-- ============================================================================

-- Allow authenticated users to INSERT/upload files
CREATE POLICY "documents_storage_insert"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'documents');

-- Allow public users to SELECT/view files
CREATE POLICY "documents_storage_select"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'documents');

-- Allow authenticated users to UPDATE files
CREATE POLICY "documents_storage_update"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'documents')
  WITH CHECK (bucket_id = 'documents');

-- Allow authenticated users to DELETE files
CREATE POLICY "documents_storage_delete"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'documents');

-- ============================================================================
-- PART 5: CREATE CLEAN STORAGE POLICIES FOR DIAGRAMS BUCKET
-- ============================================================================

-- Allow authenticated users to INSERT/upload files
CREATE POLICY "diagrams_storage_insert"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'diagrams');

-- Allow public users to SELECT/view files
CREATE POLICY "diagrams_storage_select"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'diagrams');

-- Allow authenticated users to UPDATE files
CREATE POLICY "diagrams_storage_update"
  ON storage.objects FOR UPDATE
  TO authenticated
  USING (bucket_id = 'diagrams')
  WITH CHECK (bucket_id = 'diagrams');

-- Allow authenticated users to DELETE files
CREATE POLICY "diagrams_storage_delete"
  ON storage.objects FOR DELETE
  TO authenticated
  USING (bucket_id = 'diagrams');

-- ============================================================================
-- PART 6: CREATE DOCUMENTS TABLE (if it doesn't exist)
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.documents (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  filename text NOT NULL,
  original_filename text NOT NULL,
  file_type text NOT NULL,
  file_size bigint NOT NULL,
  storage_path text NOT NULL,
  storage_bucket text NOT NULL DEFAULT 'documents',
  category text NOT NULL DEFAULT 'general',
  description text,
  tags text[],
  uploaded_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_documents_uploaded_by ON public.documents(uploaded_by);
CREATE INDEX IF NOT EXISTS idx_documents_category ON public.documents(category);
CREATE INDEX IF NOT EXISTS idx_documents_created_at ON public.documents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_documents_file_type ON public.documents(file_type);

-- ============================================================================
-- PART 7: CREATE CLEAN TABLE POLICIES FOR DOCUMENTS TABLE
-- ============================================================================

-- Clean up existing policies
DROP POLICY IF EXISTS "Authenticated users can view all documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can upload documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can create documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can insert documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can update documents" ON public.documents;
DROP POLICY IF EXISTS "Authenticated users can delete documents" ON public.documents;
DROP POLICY IF EXISTS "documents_table_select" ON public.documents;
DROP POLICY IF EXISTS "documents_table_insert" ON public.documents;
DROP POLICY IF EXISTS "documents_table_update" ON public.documents;
DROP POLICY IF EXISTS "documents_table_delete" ON public.documents;

-- Create new clean policies
CREATE POLICY "documents_table_select"
  ON public.documents FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "documents_table_insert"
  ON public.documents FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "documents_table_update"
  ON public.documents FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "documents_table_delete"
  ON public.documents FOR DELETE
  TO authenticated
  USING (true);

-- ============================================================================
-- VERIFICATION: Check that everything was created successfully
-- ============================================================================

-- List all buckets
SELECT id, name, public, file_size_limit 
FROM storage.buckets 
WHERE id IN ('documents', 'diagrams')
ORDER BY id;

-- List all storage policies for our buckets
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies
WHERE tablename = 'objects'
  AND (policyname LIKE '%documents%' OR policyname LIKE '%diagrams%')
ORDER BY policyname;

-- List all table policies for documents table
SELECT schemaname, tablename, policyname, cmd, roles
FROM pg_policies
WHERE tablename = 'documents'
ORDER BY policyname;

-- ============================================================================
-- SUCCESS!
-- ============================================================================
-- If you see results from the verification queries above, the fix was applied.
-- 
-- You should see:
-- - 2 buckets (documents, diagrams)
-- - 8 storage policies (4 for each bucket: insert, select, update, delete)
-- - 4 table policies for documents table
--
-- Now test uploading a document or image in your app - it should work!
-- ============================================================================
