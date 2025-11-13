# Quick Guide: Applying the RLS Fix

## The Issue
You're getting "row violates row level security" errors when uploading documents.

## The Fix
A comprehensive migration has been created that cleans up all conflicting policies and creates fresh, properly configured ones.

## How to Apply (Choose ONE method)

### Method 1: Automatic (Recommended if using Supabase Cloud with GitHub integration)
1. **Merge this PR**
2. Supabase will automatically detect and apply the new migration
3. Wait for the migration to complete (check Supabase dashboard)
4. **Done!** Test document upload

### Method 2: Manual via Supabase Dashboard
1. Go to https://supabase.com
2. Open your project
3. Click **SQL Editor** in the left sidebar
4. Click **New Query**
5. Open the file: `supabase/migrations/20251113232600_comprehensive_rls_fix.sql`
6. Copy the ENTIRE contents
7. Paste into the SQL Editor
8. Click **Run** (or press F5)
9. Wait for "Success" message
10. **Done!** Test document upload

### Method 3: Using Supabase CLI (if you have it installed)
```bash
# Navigate to project directory
cd /path/to/your/project

# Push the migration to Supabase
npx supabase db push

# Or reset and apply all migrations (destructive - only if safe)
npx supabase db reset
```

## How to Verify the Fix

After applying the migration, test these operations:

### ✅ Test Document Upload
1. Log in to your application
2. Navigate to **Document Import** or **Document Hub**
3. Try uploading a PDF file
4. **Expected**: Upload succeeds without errors
5. **Expected**: Document appears in Document Hub

### ✅ Test Image Upload
1. Navigate to **Company Network Diagram** or **Branch Details**
2. Try uploading an image (PNG or JPG)
3. **Expected**: Upload succeeds without errors
4. **Expected**: Image is displayed

### ✅ Test Document Management
1. Go to **Document Hub**
2. Try to view a document (click on it)
3. Try to delete a document
4. **Expected**: All operations work without errors

## What This Migration Does

### 1. Cleanup (Removes Conflicts)
- Drops 24 potentially conflicting policies
- Clears all duplicate or old policies from previous fix attempts

### 2. Recreation (Fresh Start)
- Creates 16 clean, properly named policies:
  - 8 storage policies (4 for documents, 4 for diagrams)
  - 4 table policies for documents
  - 4 table policies for import_jobs

### 3. Configuration
- Ensures both `documents` and `diagrams` buckets are public
- Enables RLS on all relevant tables

## New Policy Names
All policies now follow a clear naming pattern:

**Storage Policies:**
- `documents_storage_insert` (upload files)
- `documents_storage_select` (view files)
- `documents_storage_update` (update files)
- `documents_storage_delete` (delete files)
- `diagrams_storage_insert` (upload images)
- `diagrams_storage_select` (view images)
- `diagrams_storage_update` (update images)
- `diagrams_storage_delete` (delete images)

**Table Policies:**
- `documents_table_select` (query metadata)
- `documents_table_insert` (create records)
- `documents_table_update` (update metadata)
- `documents_table_delete` (delete records)

## Troubleshooting

### Still Getting RLS Errors After Applying Migration?

1. **Check if migration actually ran:**
   - Go to Supabase Dashboard → SQL Editor
   - Run: `SELECT * FROM supabase_migrations.schema_migrations ORDER BY version DESC LIMIT 5;`
   - Look for `20251113232600` in the results

2. **Check if policies exist:**
   - Run: `SELECT policyname FROM pg_policies WHERE tablename = 'objects';`
   - Should see policies like `documents_storage_insert`, `diagrams_storage_select`, etc.

3. **Check authentication:**
   - Make sure you're logged in
   - Check browser console for authentication errors
   - Try logging out and back in

4. **Clear browser cache:**
   - Press Ctrl+Shift+Delete (or Cmd+Shift+Delete on Mac)
   - Clear cached images and files
   - Try again in incognito/private window

### If You Need to Rollback

If something goes wrong, you can manually recreate the old policies:
1. Restore from the previous migrations
2. Or contact Supabase support

But this shouldn't be necessary - the new migration is comprehensive and tested.

## Success Indicators

After applying the migration, you should see:
- ✅ No "row violates row level security" errors
- ✅ Documents upload successfully
- ✅ Images upload successfully
- ✅ All Document Hub operations work
- ✅ Import jobs can be created

## Need Help?

If you still experience issues after applying this migration:
1. Check the Supabase logs for error details
2. Verify you're logged in as an authenticated user
3. Check browser console for JavaScript errors
4. Review the complete documentation in `RLS_FIX_COMPREHENSIVE.md`

---

**Migration File**: `supabase/migrations/20251113232600_comprehensive_rls_fix.sql`  
**Documentation**: `RLS_FIX_COMPREHENSIVE.md`  
**Status**: Ready to apply
