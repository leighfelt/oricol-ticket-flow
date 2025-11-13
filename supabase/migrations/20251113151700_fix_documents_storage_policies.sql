-- Fix missing storage policies for documents bucket
-- This migration adds the required RLS policies for the documents storage bucket
-- to prevent "new row violates row level security" errors

-- Drop existing policies if they exist (to ensure clean state)
DROP POLICY IF EXISTS "Authenticated users can upload documents to storage" ON storage.objects;
DROP POLICY IF EXISTS "Public users can view documents in storage" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can update documents in storage" ON storage.objects;
DROP POLICY IF EXISTS "Authenticated users can delete documents from storage" ON storage.objects;

-- Create storage policies for documents bucket
-- These policies allow authenticated users to upload, update, and delete files
-- and allow public users to view files (required for document viewing in the app)

CREATE POLICY "Authenticated users can upload documents to storage"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'documents');

CREATE POLICY "Public users can view documents in storage"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'documents');

CREATE POLICY "Authenticated users can update documents in storage"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'documents')
WITH CHECK (bucket_id = 'documents');

CREATE POLICY "Authenticated users can delete documents from storage"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'documents');

-- Update the bucket to be public (required for viewing documents in the app)
UPDATE storage.buckets 
SET public = true 
WHERE id = 'documents';
