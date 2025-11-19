# 🎯 START HERE: Working on Lovable

Welcome! This guide helps you work with database (SQL) changes on **Lovable** when you can't run CLI commands.

---

## 📌 Quick Links

### Need to Run Migrations?
**→ [HOW_TO_RUN_MIGRATIONS_ON_LOVABLE.md](./HOW_TO_RUN_MIGRATIONS_ON_LOVABLE.md)** - ⚡ Quick answer: what file to overwrite

**→ [LOVABLE_MIGRATION_GUIDE.md](./LOVABLE_MIGRATION_GUIDE.md)** - Complete migration guide (copy & overwrite method)

### Need to Edit SQL?
**→ [LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** - Complete guide for editing SQL without CLI

**→ [LOVABLE_SQL_CHEATSHEET.md](./LOVABLE_SQL_CHEATSHEET.md)** - Quick reference & cheat sheet

### Need to Fix Upload Errors?
**→ [QUICKFIX_START_HERE.md](./QUICKFIX_START_HERE.md)** - Fix "Row Level Security" errors in 2 minutes

**→ [FIX_RLS_NOW.sql](./FIX_RLS_NOW.sql)** - Ready-to-use SQL fix (just paste and run)

### Need to Fix Shared Folders or User Groups?
**→ [QUICK_FIX_SHARED_FOLDERS.md](./QUICK_FIX_SHARED_FOLDERS.md)** - Fix "table not found" errors for shared folders

**→ [LOVABLE_FIX_ALL_TABLES.sql](./LOVABLE_FIX_ALL_TABLES.sql)** - Complete fix for all tables (just paste and run)

**→ [FIX_SUMMARY_LOVABLE_SQL.md](./FIX_SUMMARY_LOVABLE_SQL.md)** - Detailed explanation of what was fixed

### Need to Find Your Supabase?
**→ [FIND_YOUR_SUPABASE_CONNECTION.md](./FIND_YOUR_SUPABASE_CONNECTION.md)** - How to access your Supabase dashboard

---

## 🚀 Common Tasks

### 1️⃣ Apply a SQL Fix (e.g., FIX_RLS_NOW.sql)
```
1. Go to: https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp
2. Click "SQL Editor" → "New Query"
3. Open FIX_RLS_NOW.sql in Lovable/GitHub
4. Copy all (Ctrl+A, Ctrl+C)
5. Paste in SQL Editor (Ctrl+V)
6. Click "Run" or press F5
7. ✅ Done!
```

### 2️⃣ Create a New Migration File
```
1. In Lovable, go to: supabase/migrations/
2. Create new file: YYYYMMDDHHMMSS_description.sql
   Example: 20251117120000_add_column.sql
3. Write your SQL in the file
4. Save (auto-commits to GitHub)
5. Copy the SQL
6. Paste and run in Supabase SQL Editor
7. ✅ Done!
```

### 3️⃣ Apply an Existing Migration
```
1. Open the migration file in supabase/migrations/
2. Copy the SQL contents
3. Go to Supabase SQL Editor
4. Paste and run
5. ✅ Done!
```

### 4️⃣ Find Your Supabase Dashboard
```
Option A: Direct link
→ https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp

Option B: Find your project ID
1. In Lovable: Settings → Environment Variables
2. Find: VITE_SUPABASE_PROJECT_ID
3. Go to: https://supabase.com/dashboard/project/[PROJECT_ID]

Option C: Check your code
1. Open: supabase/config.toml
2. Find: project_id = "..."
3. Use that ID in the URL above
```

---

## 🎓 Learn More

### Lovable-Specific Guides
- **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** - How to edit SQL without CLI (MUST READ!)
- **[LOVABLE_SQL_CHEATSHEET.md](./LOVABLE_SQL_CHEATSHEET.md)** - Quick reference guide
- **[LOVABLE_SQL_FAQ.md](./LOVABLE_SQL_FAQ.md)** - Frequently asked questions

### Migration Guides
- **[MIGRATION_QUICKSTART.md](./MIGRATION_QUICKSTART.md)** - Quick migration guide
- **[MIGRATION_CHEATSHEET.md](./MIGRATION_CHEATSHEET.md)** - Migration commands reference
- **[SUPABASE_MIGRATIONS.md](./SUPABASE_MIGRATIONS.md)** - Complete migration documentation

### Troubleshooting & Fixes
- **[QUICKFIX_START_HERE.md](./QUICKFIX_START_HERE.md)** - Fix upload/RLS errors
- **[QUICK_FIX_SHARED_FOLDERS.md](./QUICK_FIX_SHARED_FOLDERS.md)** - Fix shared folders/groups errors
- **[FIX_RLS_NOW.sql](./FIX_RLS_NOW.sql)** - SQL fix for storage errors
- **[LOVABLE_FIX_ALL_TABLES.sql](./LOVABLE_FIX_ALL_TABLES.sql)** - SQL fix for all tables
- **[FIX_SUMMARY_LOVABLE_SQL.md](./FIX_SUMMARY_LOVABLE_SQL.md)** - Detailed fix documentation
- **[FIND_YOUR_SUPABASE_CONNECTION.md](./FIND_YOUR_SUPABASE_CONNECTION.md)** - Find your Supabase

### General Setup
- **[README.md](./README.md)** - Main project documentation
- **[LOCAL_SETUP.md](./LOCAL_SETUP.md)** - Local development setup
- **[DEPLOYMENT.md](./DEPLOYMENT.md)** - Deployment options

---

## 🔑 Key Concepts

### What is SQL?
SQL is the language used to interact with databases. When you need to change your database structure (add tables, columns, policies, etc.), you write SQL.

### What are Migrations?
Migrations are SQL files that describe database changes. They're stored in `supabase/migrations/` and applied to your database to keep it up-to-date.

### What is the Supabase SQL Editor?
The Supabase SQL Editor is a web-based tool where you can write and run SQL directly on your database. You can access it at:
```
https://supabase.com/dashboard/project/[YOUR_PROJECT_ID]/sql
```

### Do I Need the CLI?
**No!** While the documentation mentions `npm run migrate`, you can do everything through the Supabase SQL Editor when working on Lovable. See the guides above for details.

---

## 💡 Pro Tips

✅ **Bookmark these links:**
- Your Supabase Dashboard: https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp
- Your GitHub Repo: https://github.com/craigfelt/oricol-ticket-flow-34e64301
- Your Lovable Project: https://lovable.dev/projects/c75c70a7-c13d-4879-a8af-bbb8cc076141

✅ **Save your SQL snippets** in the Supabase SQL Editor for easy reuse

✅ **Test SQL on a development database first** before running on production

✅ **Always use IF EXISTS / IF NOT EXISTS** in your SQL to make it safer

✅ **Create migration files** even when using SQL Editor directly (for version control)

---

## 🆘 Need Help?

1. **Check the guides** listed above - they answer most questions!
2. **Look at existing migration files** in `supabase/migrations/` for examples
3. **Check the Supabase documentation**: https://supabase.com/docs
4. **Ask in the Lovable community** or contact support

---

## ✨ Quick Summary

**You're on Lovable and need to edit SQL?**

1. **Don't worry about the CLI!** You can do everything in the Supabase SQL Editor
2. **Read**: [LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)
3. **Access your Supabase**: https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp
4. **Write/paste SQL** in the SQL Editor and run it
5. **(Optional)** Save to a migration file in `supabase/migrations/` for version control

**That's it!** 🎉

---

**Last Updated**: November 2025
