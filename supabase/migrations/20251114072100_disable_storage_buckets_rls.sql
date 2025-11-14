-- Disable RLS on storage.buckets to fix permission errors
-- 
-- PROBLEM:
-- The previous migration (20251114070500) enabled RLS on storage.buckets and added a policy.
-- However, storage.buckets is a system table and should NOT have RLS enabled.
-- Enabling RLS on system tables can cause unexpected permission errors and break
-- normal storage operations including getBucket() calls.
--
-- SOLUTION:
-- Disable RLS on storage.buckets and remove all policies.
-- The storage.buckets table is metadata about buckets and does not contain sensitive data.
-- Access to actual files is controlled by RLS policies on storage.objects, not storage.buckets.
-- ============================================================================

-- Drop all RLS policies on storage.buckets
DROP POLICY IF EXISTS "Allow public read access to buckets" ON storage.buckets;
DROP POLICY IF EXISTS "Allow authenticated users to read buckets" ON storage.buckets;
DROP POLICY IF EXISTS "Public can view buckets" ON storage.buckets;
DROP POLICY IF EXISTS "Authenticated users can view buckets" ON storage.buckets;

-- DISABLE RLS on storage.buckets (this is the fix)
-- System tables should not have RLS enabled
ALTER TABLE storage.buckets DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- VERIFICATION:
-- After applying this migration:
-- 1. Log in as a regular user
-- 2. Try to upload a document or image
-- 3. The app should work without permission errors
-- 4. The getBucket() call in uploadService.ts should work correctly
-- ============================================================================

-- EXPLANATION:
-- RLS should be enabled on:
-- - storage.objects (controls access to actual files) ✓ ENABLED
-- - public.documents (controls access to document metadata) ✓ ENABLED  
-- - Other application tables ✓ ENABLED
--
-- RLS should NOT be enabled on:
-- - storage.buckets (system metadata table) ✗ NOW DISABLED
-- - Other system tables in the storage schema ✗ DISABLED
-- ============================================================================
