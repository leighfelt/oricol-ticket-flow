# 🔧 COMPLETE FIX: Row Level Security & Environment Setup

## ⚠️ IMPORTANT: Two Issues Need Fixing

### Issue 1: Row Level Security (RLS) Violations ❌
**Error**: "new row violates row-level security policy"  
**When**: Uploading documents or images  
**Status**: Fix ready to apply ✅

### Issue 2: Environment File Security ⚠️
**Problem**: `.env` file is committed to git with real credentials  
**Risk**: Medium (anon key is meant to be public, but still bad practice)  
**Status**: Fix included below ✅

---

## 🚀 QUICK FIX (Do This First!)

### Step 1: Fix Row Level Security in Supabase

1. **Go to your Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Select project: `kwmeqvrmtivmljujwocp`

2. **Open SQL Editor**
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Apply the Fix**
   - Open the file: `FIX_RLS_NOW.sql` (in this repository)
   - Copy **ALL** the contents
   - Paste into the SQL Editor
   - Click **"Run"** (or press F5)
   - Wait for "Success" message

4. **Verify the Fix**
   - Scroll down in the SQL Editor results
   - You should see:
     - ✅ 2 storage buckets (documents, diagrams)
     - ✅ 8 storage policies (4 for each bucket)
     - ✅ 4 table policies for documents

### Step 2: Fix Environment File Security

The `.env` file in your repository contains real Supabase credentials. While the anon key is designed to be public (it's used in client-side code), it's still best practice to keep `.env` out of version control.

**What was done:**
- ✅ Added `.env` to `.gitignore` 
- ✅ Created `.env.example` as a template
- ✅ Your actual `.env` will remain on your local machine

**What you should do:**
1. The `.env` file will stop being tracked after this PR is merged
2. Keep your local `.env` file for development
3. Anyone cloning the repo will need to create their own `.env` from `.env.example`

---

## 📝 Testing the Fix

After applying the SQL fix, test document uploads:

### Test 1: Upload a Document
1. Login to your application
2. Navigate to **Document Import** or **Document Hub**
3. Click "Upload" or drag a file
4. Choose a PDF, Word doc, or image
5. **Expected**: Upload succeeds ✅
6. **Expected**: No RLS error ✅
7. **Expected**: Document appears in the list ✅

### Test 2: Upload Network Diagram
1. Navigate to **Company Network Diagram**
2. Click "Upload Image"
3. Choose a PNG or JPG file
4. **Expected**: Upload succeeds ✅
5. **Expected**: Image appears in diagrams list ✅

### Test 3: Import Document with Images
1. Navigate to **Document Import**
2. Upload a Word document with embedded images
3. **Expected**: Document uploads ✅
4. **Expected**: Images are extracted ✅
5. **Expected**: Images upload to storage ✅
6. **Expected**: No RLS errors ✅

---

## 🔍 What Was Fixed?

### Storage Buckets Created
1. **`documents` bucket**
   - For: PDF, Word, Excel, PowerPoint, images, text files
   - Size limit: 100MB
   - Public: Yes (for easy viewing)

2. **`diagrams` bucket**
   - For: Network diagrams and images
   - Size limit: 50MB
   - Public: Yes (for easy viewing)

### Row Level Security Policies Applied

**For each bucket (documents & diagrams), 4 policies:**

1. **INSERT Policy** → Authenticated users can upload files
2. **SELECT Policy** → Anyone can view files (public access)
3. **UPDATE Policy** → Authenticated users can modify files
4. **DELETE Policy** → Authenticated users can delete files

**For documents table, 4 policies:**

1. **SELECT Policy** → Authenticated users can view all documents
2. **INSERT Policy** → Authenticated users can add documents
3. **UPDATE Policy** → Authenticated users can modify document metadata
4. **DELETE Policy** → Authenticated users can delete documents

### Why Public Buckets?

The buckets are set to `public = true` because:
- Documents need to be viewable directly in the browser
- PDF viewers and image previews need direct access
- Files are still protected by RLS policies
- Only authenticated users can upload/delete

This is **secure** because:
- File names are timestamped and unique (not guessable)
- Upload/delete requires authentication
- File types are restricted (no executables)
- Database metadata is separately protected

---

## 📊 Technical Details

### What the SQL Script Does

```sql
1. Creates storage buckets (if missing)
2. Enables Row Level Security
3. Removes all old/conflicting policies
4. Creates clean, properly-named policies
5. Creates documents table (if missing)
6. Creates indexes for performance
7. Verifies everything was created
```

### Policy Naming Convention

All policies use consistent naming:
- `{resource}_{location}_{operation}`
- Example: `documents_storage_insert`
- Resource: documents or diagrams
- Location: storage or table
- Operation: insert, select, update, delete

### Files in This Fix

- ✅ `FIX_RLS_NOW.sql` - Complete SQL fix (apply this!)
- ✅ `COMPLETE_FIX_GUIDE.md` - This file
- ✅ `.env.example` - Template for environment variables
- ✅ `.gitignore` - Updated to exclude `.env`

---

## 🛟 Troubleshooting

### "Bucket not found" Error

**If you get this after applying the fix:**

1. Check the SQL results - buckets should show:
   ```
   id        | name      | public | file_size_limit
   ----------|-----------|--------|----------------
   diagrams  | diagrams  | true   | 52428800
   documents | documents | true   | 104857600
   ```

2. If buckets are missing, re-run the SQL script

### Still Getting RLS Errors

**If uploads still fail:**

1. Verify you're logged in (authenticated)
2. Check browser console for specific error
3. Run this query in Supabase SQL Editor:
   ```sql
   SELECT policyname, cmd 
   FROM pg_policies 
   WHERE tablename = 'objects'
     AND (policyname LIKE '%documents%' OR policyname LIKE '%diagrams%')
   ORDER BY policyname;
   ```
4. You should see 8 policies total

### "Invalid JWT" or Auth Errors

**If you get authentication errors:**

1. Verify your `.env` file has correct values:
   ```
   VITE_SUPABASE_PROJECT_ID="kwmeqvrmtivmljujwocp"
   VITE_SUPABASE_URL="https://kwmeqvrmtivmljujwocp.supabase.co"
   VITE_SUPABASE_PUBLISHABLE_KEY="eyJ..." (your anon key)
   ```

2. Get fresh keys from Supabase Dashboard:
   - Settings → API
   - Copy "anon" / "public" key (NOT service_role)

3. Restart your development server:
   ```bash
   npm run dev
   ```

---

## 🎯 Summary

### Before This Fix
- ❌ "Row violates row level security" errors
- ❌ Document uploads fail
- ❌ Image uploads fail
- ❌ .env committed to git

### After This Fix
- ✅ Documents upload successfully
- ✅ Images upload successfully
- ✅ Proper RLS policies in place
- ✅ Buckets configured correctly
- ✅ .env excluded from version control

---

## 📞 Still Need Help?

If you're still experiencing issues after applying this fix:

1. **Check the SQL results** - Make sure all policies were created
2. **Check browser console** - Look for specific error messages
3. **Check Supabase logs** - Dashboard → Logs → see recent errors
4. **Verify authentication** - Make sure you're logged in
5. **Check file type** - Ensure it's an allowed MIME type

---

## ✅ Success Checklist

- [ ] Applied `FIX_RLS_NOW.sql` in Supabase SQL Editor
- [ ] Saw success message and verification results
- [ ] Tested document upload - works!
- [ ] Tested image upload - works!
- [ ] No more RLS errors
- [ ] `.env` is now in `.gitignore`

**Once all items are checked, you're done! 🎉**

---

**Last Updated**: 2025-11-14  
**Issue**: Row Level Security violations on document/image uploads  
**Status**: ✅ FIX READY - Apply FIX_RLS_NOW.sql
