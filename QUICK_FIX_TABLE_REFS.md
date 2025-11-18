# 🚀 Quick Fix: Table Reference Issues on Lovable

If you're getting errors like "relation does not exist" or "table not found" when running SQL on Lovable, this guide will help you fix it in **2 minutes**.

## The Problem

You're trying to run SQL queries but getting errors like:
- ❌ `ERROR: relation "public.documents" does not exist`
- ❌ `ERROR: table "public.shared_files" does not exist`
- ❌ `ERROR: foreign key constraint fails`

This happens because the database tables haven't been created yet.

## ✅ The Solution (2 Minutes)

### Step 1: Open Lovable SQL Editor
1. Go to your Lovable project
2. Click **"Database"** or **"Supabase"** in the left sidebar
3. Click **"SQL Editor"**

### Step 2: Run the Fix Script
1. Open the file `LOVABLE_FIX_ALL_TABLES.sql` from this repository
2. **Copy the ENTIRE contents** of the file
3. Paste it into the Lovable SQL Editor
4. Click **"Run"** or **"Execute"**

### Step 3: Verify It Worked
You should see success messages like:
```
✅ All tables created successfully!
✅ Documents table created!
✅ All RLS policies fixed!
✅ Shared Files system is ready to use!
```

### Step 4: Confirm Tables Exist (Optional)
1. Open the file `VERIFY_TABLES_EXIST.sql`
2. Copy and paste into SQL Editor
3. Click **"Run"**
4. Check that all tables show as "✅ Table exists"

## 🎉 Done!

Your database is now set up correctly and you can run SQL queries without errors.

---

## 🔧 What If It Still Doesn't Work?

### Error: "syntax error near..."
**Solution:** Make sure you copied the **ENTIRE** SQL file, including the first and last lines.

### Error: "permission denied"
**Solution:** Make sure you're logged into Lovable with an account that has database access.

### Error: "duplicate key value"
**Solution:** This is okay! It means the tables already exist. Your database is fine.

### Tables still missing?
**Solution:** Try running the verification script `VERIFY_TABLES_EXIST.sql` to see which tables are missing, then check the error messages.

---

## 🌟 Want to Run Fully Local Instead?

If you want to run the entire app locally on your computer without Lovable or cloud services:

1. See **[LOCAL_SETUP.md](./LOCAL_SETUP.md)** for a complete guide
2. Takes about 5 minutes to set up
3. 100% free, no cloud costs
4. Works offline after initial setup

---

## 📚 What Tables Are Created?

The fix script creates these tables:
- ✅ `documents` - Document storage and metadata
- ✅ `user_groups` - User groups for permissions
- ✅ `user_group_members` - Group membership
- ✅ `group_permissions` - Group-level permissions
- ✅ `user_permissions` - Individual user permissions
- ✅ `shared_files` - File sharing between users
- ✅ `shared_folders` - Folder organization
- ✅ `shared_folder_files` - Files in shared folders
- ✅ `shared_folder_permissions` - Folder access control

All tables include:
- Row Level Security (RLS) policies for data protection
- Proper indexes for performance
- Foreign key relationships for data integrity

---

## 🆘 Still Need Help?

1. Check the main [README.md](./README.md) for more documentation
2. Look at [LOVABLE_START_HERE.md](./LOVABLE_START_HERE.md) for Lovable-specific guides
3. See [LOVABLE_SQL_FAQ.md](./LOVABLE_SQL_FAQ.md) for common questions

---

## 💡 Pro Tips

- The fix script is **safe to run multiple times** (uses `IF NOT EXISTS`)
- All RLS policies are automatically enabled for security
- You can view and edit data in Lovable's Table Editor after running the script
- The script creates all necessary indexes for optimal performance

**Happy coding! 🎉**
