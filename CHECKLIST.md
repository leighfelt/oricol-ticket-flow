# ✅ RLS Fix Checklist

Use this checklist to apply the Row Level Security fix and verify it works.

---

## 🔧 Application Steps

### 1. Merge Pull Request
- [ ] Review the PR changes
- [ ] Click "Merge Pull Request"
- [ ] Confirm merge

### 2. Apply SQL Fix in Supabase (2 minutes)
- [ ] Go to https://supabase.com/dashboard
- [ ] Select your project: `kwmeqvrmtivmljujwocp`
- [ ] Click "SQL Editor" in the left sidebar
- [ ] Click "New Query" button
- [ ] Open `FIX_RLS_NOW.sql` from the repository
- [ ] Select all (Ctrl+A) and copy (Ctrl+C)
- [ ] Paste into SQL Editor (Ctrl+V)
- [ ] Click "Run" button (or press F5)
- [ ] Wait for "Success" message
- [ ] Scroll down to see verification results

**Expected Results:**
- [ ] See 2 storage buckets listed (documents, diagrams)
- [ ] See 8 storage policies listed
- [ ] See 1 documents table
- [ ] See 4 table policies listed
- [ ] No error messages

---

## ✅ Verification Steps

### 3. Verify Fix Was Applied (Optional)
- [ ] In Supabase SQL Editor, click "New Query"
- [ ] Open `VERIFY_FIX.sql` from the repository
- [ ] Copy and paste into SQL Editor
- [ ] Click "Run"
- [ ] Check all rows show ✅ OK status

### 4. Test Document Upload
- [ ] Open your application
- [ ] Login with your account
- [ ] Navigate to "Document Import" or "Document Hub"
- [ ] Click upload button
- [ ] Select a PDF file
- [ ] Click upload
- [ ] ✅ **SUCCESS:** No RLS error!
- [ ] ✅ **SUCCESS:** File uploads successfully!
- [ ] ✅ **SUCCESS:** Document appears in the list!

### 5. Test Image Upload
- [ ] Navigate to "Company Network Diagram" page
- [ ] Click "Upload Image" button
- [ ] Select a PNG or JPG image
- [ ] Fill in name and description
- [ ] Click "Upload"
- [ ] ✅ **SUCCESS:** No RLS error!
- [ ] ✅ **SUCCESS:** Image uploads successfully!
- [ ] ✅ **SUCCESS:** Image appears in diagrams list!

### 6. Test Document with Images
- [ ] Navigate to "Document Import"
- [ ] Select a Word document with embedded images
- [ ] Upload the document
- [ ] ✅ **SUCCESS:** Document uploads!
- [ ] ✅ **SUCCESS:** Images are extracted!
- [ ] ✅ **SUCCESS:** Images upload to storage!
- [ ] ✅ **SUCCESS:** No RLS errors!

---

## 🎉 Completion

### All Tests Passed?
- [ ] All upload tests completed successfully
- [ ] No "row violates row level security" errors
- [ ] Documents and images appear in the app
- [ ] Users can view uploaded files

### If Everything Works:
**🎉 CONGRATULATIONS! The RLS fix has been successfully applied!**

You can now:
- ✅ Upload documents without errors
- ✅ Upload images without errors
- ✅ Use document import features
- ✅ Extract and upload images from documents

---

## 🆘 If Something Doesn't Work

### Troubleshooting
- [ ] Check you ran the **complete** SQL script (all of FIX_RLS_NOW.sql)
- [ ] Verify you're logged in to the application
- [ ] Check browser console (F12) for specific errors
- [ ] Run `VERIFY_FIX.sql` to see what's missing
- [ ] Review troubleshooting section in `COMPLETE_FIX_GUIDE.md`

### Still Having Issues?
1. Check Supabase logs: Dashboard → Logs
2. Verify authentication is working
3. Check file type is allowed
4. See `COMPLETE_FIX_GUIDE.md` for detailed troubleshooting

---

## 📚 Reference Documents

If you need help at any step:

| Issue | Document |
|-------|----------|
| Quick guide | `QUICKFIX_START_HERE.md` |
| Detailed help | `COMPLETE_FIX_GUIDE.md` |
| Verification | `VERIFY_FIX.sql` |
| This checklist | `CHECKLIST.md` |

---

**Estimated Time:** 5-10 minutes  
**Difficulty:** Easy  
**Required Access:** Supabase dashboard admin access

**Once all items are checked, you're done! 🚀**
