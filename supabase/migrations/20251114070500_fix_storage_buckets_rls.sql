-- Fix RLS policies for storage.buckets table
-- This resolves "you do not have access to perform this function" errors
-- when the application tries to query bucket information

-- ============================================================================
-- PROBLEM:
-- The storage.buckets table has RLS enabled by default but no policies
-- This causes permission errors when the app calls supabase.storage.getBucket()
-- ============================================================================

-- Enable RLS on storage.buckets if not already enabled
ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

-- Drop any existing policies to avoid conflicts
DROP POLICY IF EXISTS "Allow public read access to buckets" ON storage.buckets;
DROP POLICY IF EXISTS "Allow authenticated users to read buckets" ON storage.buckets;
DROP POLICY IF EXISTS "Public can view buckets" ON storage.buckets;
DROP POLICY IF EXISTS "Authenticated users can view buckets" ON storage.buckets;

-- Create policy to allow all users (including authenticated and anon) to view bucket information
-- This is safe because bucket information is not sensitive and is needed for the app to function
CREATE POLICY "Allow public read access to buckets"
  ON storage.buckets
  FOR SELECT
  TO public
  USING (true);

-- Note: We only allow SELECT (read) operations on storage.buckets
-- INSERT, UPDATE, DELETE operations remain restricted to service role/admins
-- This follows the principle of least privilege while allowing necessary functionality

-- ============================================================================
-- VERIFICATION:
-- After applying this migration, test by:
-- 1. Logging in as a regular user
-- 2. Trying to upload a document or image
-- 3. The app should be able to query bucket info without permission errors
-- ============================================================================
