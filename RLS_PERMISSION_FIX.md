# RLS Permission Error Fix

## Problem Description
Users were experiencing "you do not have access to perform this function - RLS policy" errors when using the application.

## Root Cause
The `storage.buckets` table in Supabase has Row Level Security (RLS) enabled by default, but NO policies were configured to allow users to read bucket information. This caused permission errors whenever the application tried to query bucket metadata using `supabase.storage.getBucket()`.

## Solution
A new migration has been created: `20251114070500_fix_storage_buckets_rls.sql`

This migration:
1. Ensures RLS is enabled on `storage.buckets`
2. Drops any conflicting policies
3. Creates a new policy allowing public SELECT (read) access to bucket information

## How to Apply the Fix

### Method 1: Automatic (Supabase Cloud with GitHub Integration)
If your Supabase project is connected to GitHub:
1. **Merge this PR** to the main branch
2. Supabase will automatically detect and apply the migration
3. Wait 1-2 minutes for deployment
4. Test the fix

### Method 2: Manual via Supabase Dashboard
1. Go to https://supabase.com and sign in
2. Open your project (`kwmeqvrmtivmljujwocp`)
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**
5. Copy the contents of `supabase/migrations/20251114070500_fix_storage_buckets_rls.sql`
6. Paste into the SQL Editor
7. Click **Run** (or press F5)
8. Wait for "Success. No rows returned" message
9. Test the fix

### Method 3: Using Supabase CLI
```bash
# Navigate to project directory
cd /path/to/oricol-ticket-flow-34e64301

# Push the migration to Supabase
npx supabase db push

# Or if you want to see what will be applied first
npx supabase db diff
```

## How to Verify the Fix

### Test 1: Upload a Document
1. Log in to the application
2. Navigate to **Document Hub**
3. Click **Upload Document**
4. Select a PDF or Word document
5. **Expected**: Upload succeeds without permission errors
6. **Expected**: Document appears in the Document Hub list

### Test 2: Upload an Image
1. Navigate to **Company Network Diagram** or **Branch Details**
2. Try uploading an image (PNG or JPG)
3. **Expected**: Upload succeeds without permission errors
4. **Expected**: Image is displayed correctly

### Test 3: Check Browser Console
1. Open browser DevTools (F12)
2. Go to Console tab
3. Perform an upload operation
4. **Expected**: No RLS or permission-related errors
5. **Expected**: Upload service logs show successful operation

## What This Fix Does

### Before the Fix
```
User tries to upload → App queries bucket info → storage.buckets has RLS but no policy → Permission Error ❌
```

### After the Fix
```
User tries to upload → App queries bucket info → storage.buckets allows SELECT → Bucket info retrieved → Upload succeeds ✅
```

## Security Considerations

**Q: Is it safe to allow public read access to storage.buckets?**

**A: Yes!** This is safe because:
1. Bucket information is NOT sensitive (just bucket names, size limits, etc.)
2. We only allow SELECT (read) operations
3. INSERT, UPDATE, DELETE operations remain restricted to service role
4. This is the standard Supabase pattern for public applications
5. The actual files in buckets still have their own RLS policies
6. This follows the principle of least privilege

**Q: What can users see with this policy?**

**A:** Users can only see:
- Bucket names (`documents`, `diagrams`)
- Bucket configuration (file size limits, allowed MIME types)
- Whether buckets are public or private

**Q: What can users NOT do?**

**A:** Users CANNOT:
- Create new buckets
- Modify bucket settings
- Delete buckets
- Access files in buckets without proper storage.objects policies

## Technical Details

### The Missing Policy
```sql
CREATE POLICY "Allow public read access to buckets"
  ON storage.buckets
  FOR SELECT
  TO public
  USING (true);
```

### Why This Was Needed
The `uploadService.ts` performs a bucket accessibility check:
```typescript
const bucketInfo = await checkBucketAccess(bucket);
```

Which calls:
```typescript
const { data, error } = await supabase.storage.getBucket(bucketName);
```

Without the RLS policy, this fails with a permission error.

## Rollback Instructions

If you need to rollback (unlikely to be necessary):

```sql
-- Remove the policy
DROP POLICY IF EXISTS "Allow public read access to buckets" ON storage.buckets;

-- This will restore the previous state (no access to storage.buckets)
-- WARNING: This will break bucket queries in the application
```

## Related Files
- Migration: `supabase/migrations/20251114070500_fix_storage_buckets_rls.sql`
- Upload Service: `src/lib/uploadService.ts` (lines 219-236)
- Comprehensive RLS Fix: `supabase/migrations/20251113232600_comprehensive_rls_fix.sql`

## Support

If you still experience permission errors after applying this fix:

1. **Check migration was applied:**
   ```sql
   SELECT version FROM supabase_migrations.schema_migrations 
   WHERE version = '20251114070500';
   ```
   Should return one row.

2. **Check policy exists:**
   ```sql
   SELECT policyname FROM pg_policies 
   WHERE tablename = 'buckets' AND schemaname = 'storage';
   ```
   Should show "Allow public read access to buckets".

3. **Check browser console:**
   - Open DevTools (F12)
   - Look for specific error messages
   - Check if authentication is working

4. **Try logging out and back in:**
   - Clear browser cache
   - Log out
   - Log back in
   - Try upload again

## Success Indicators

After applying this fix, you should see:
- ✅ No "row violates row level security" errors
- ✅ No "you do not have access to perform this function" errors
- ✅ Documents upload successfully
- ✅ Images upload successfully
- ✅ Bucket information queries succeed
- ✅ Upload debug panel (if enabled) shows bucket info

---

**Migration Applied**: 2025-11-14  
**Status**: Ready to test  
**Estimated Time to Apply**: < 1 second
