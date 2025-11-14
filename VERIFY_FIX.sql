-- ============================================================================
-- VERIFICATION SCRIPT: Check if RLS Fix Was Applied
-- ============================================================================
-- Run this in Supabase SQL Editor to verify the fix was applied correctly
-- ============================================================================

-- Check 1: Verify storage buckets exist
SELECT 
  'Storage Buckets Check' as check_name,
  id, 
  name, 
  public, 
  file_size_limit,
  CASE 
    WHEN id IN ('documents', 'diagrams') THEN '✅ OK'
    ELSE '❌ Missing'
  END as status
FROM storage.buckets 
WHERE id IN ('documents', 'diagrams')
ORDER BY id;

-- Check 2: Count storage policies for documents bucket
SELECT 
  'Documents Storage Policies Count' as check_name,
  COUNT(*) as policy_count,
  CASE 
    WHEN COUNT(*) = 4 THEN '✅ OK - All 4 policies present'
    ELSE '❌ MISSING - Should have 4 policies (INSERT, SELECT, UPDATE, DELETE)'
  END as status
FROM pg_policies
WHERE tablename = 'objects'
  AND policyname LIKE '%documents%storage%';

-- Check 3: Count storage policies for diagrams bucket
SELECT 
  'Diagrams Storage Policies Count' as check_name,
  COUNT(*) as policy_count,
  CASE 
    WHEN COUNT(*) = 4 THEN '✅ OK - All 4 policies present'
    ELSE '❌ MISSING - Should have 4 policies (INSERT, SELECT, UPDATE, DELETE)'
  END as status
FROM pg_policies
WHERE tablename = 'objects'
  AND policyname LIKE '%diagrams%storage%';

-- Check 4: Verify documents table exists
SELECT 
  'Documents Table Check' as check_name,
  tablename,
  '✅ OK - Table exists' as status
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename = 'documents';

-- Check 5: Count table policies for documents table
SELECT 
  'Documents Table Policies Count' as check_name,
  COUNT(*) as policy_count,
  CASE 
    WHEN COUNT(*) = 4 THEN '✅ OK - All 4 policies present'
    ELSE '❌ MISSING - Should have 4 policies (SELECT, INSERT, UPDATE, DELETE)'
  END as status
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'documents';

-- Check 6: List all storage policies (for detailed review)
SELECT 
  'Detailed Storage Policies' as section,
  policyname,
  cmd as operation,
  qual as using_clause,
  with_check
FROM pg_policies
WHERE tablename = 'objects'
  AND (policyname LIKE '%documents%' OR policyname LIKE '%diagrams%')
ORDER BY policyname;

-- Check 7: List all documents table policies (for detailed review)
SELECT 
  'Detailed Documents Table Policies' as section,
  policyname,
  cmd as operation,
  qual as using_clause,
  with_check
FROM pg_policies
WHERE schemaname = 'public'
  AND tablename = 'documents'
ORDER BY policyname;

-- ============================================================================
-- SUMMARY: What You Should See
-- ============================================================================
-- 
-- Check 1: 2 buckets (documents ✅, diagrams ✅)
-- Check 2: 4 policies for documents storage ✅
-- Check 3: 4 policies for diagrams storage ✅
-- Check 4: documents table exists ✅
-- Check 5: 4 policies for documents table ✅
-- Check 6: 8 storage policies listed (detailed)
-- Check 7: 4 table policies listed (detailed)
--
-- Total Expected:
-- - 2 storage buckets
-- - 8 storage policies (4 per bucket)
-- - 1 documents table
-- - 4 table policies
--
-- If all checks show ✅, the fix was applied successfully!
-- You can now upload documents and images without RLS errors.
-- ============================================================================
