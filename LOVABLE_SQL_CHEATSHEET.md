# Lovable SQL Editing Cheat Sheet

Quick reference for editing SQL on Lovable without CLI access.

---

## 🎯 Quick Start (3 Steps)

```
1. Find your Supabase dashboard
   → Lovable Settings → Environment Variables
   → Get VITE_SUPABASE_PROJECT_ID
   → Go to: https://supabase.com/dashboard/project/[PROJECT_ID]

2. Open SQL Editor
   → Click "SQL Editor" in sidebar
   → Click "New Query"

3. Paste and Run SQL
   → Paste your SQL
   → Press F5 or click "Run"
   → ✅ Done!
```

---

## 📍 Your Project Info

```
Project ID:      kwmeqvrmtivmljujwocp
Dashboard:       https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp
SQL Editor:      [Dashboard] → SQL Editor
GitHub:          https://github.com/craigfelt/oricol-ticket-flow-34e64301
Lovable:         https://lovable.dev/projects/c75c70a7-c13d-4879-a8af-bbb8cc076141
```

---

## 🔧 Common Tasks

### Fix Upload Errors (RLS)
```
1. Open FIX_RLS_NOW.sql file in GitHub/Lovable
2. Copy all contents (Ctrl+A, Ctrl+C)
3. Paste in Supabase SQL Editor
4. Run (F5)
```

### Create Migration File
```
File location:  supabase/migrations/
File name:      YYYYMMDDHHMMSS_description.sql
Example:        20251117120000_add_column.sql

1. Create file in Lovable
2. Write SQL
3. Save (auto-commits to GitHub)
4. Copy contents
5. Run in Supabase SQL Editor
```

### Add New Table
```sql
CREATE TABLE IF NOT EXISTS public.my_table (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

ALTER TABLE public.my_table ENABLE ROW LEVEL SECURITY;
```

### Add Column to Existing Table
```sql
ALTER TABLE public.tickets 
  ADD COLUMN IF NOT EXISTS my_column text;
```

### Update RLS Policy
```sql
DROP POLICY IF EXISTS "old_policy" ON public.tickets;

CREATE POLICY "new_policy"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (true);
```

### Create Storage Bucket
```sql
INSERT INTO storage.buckets (id, name, public)
VALUES ('my-bucket', 'my-bucket', true)
ON CONFLICT (id) DO NOTHING;

CREATE POLICY "Allow uploads"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'my-bucket');
```

---

## 🔍 Finding Your Supabase

### Method 1: Lovable Environment Variables
```
Lovable → Settings → Environment Variables
Look for: VITE_SUPABASE_PROJECT_ID
```

### Method 2: Code Files
```
supabase/config.toml  → project_id = "..."
.env                  → VITE_SUPABASE_PROJECT_ID=...
```

### Method 3: Browser Console
```javascript
// In your app, press F12, then paste:
console.log(import.meta.env.VITE_SUPABASE_PROJECT_ID)
```

---

## ⚡ SQL Editor Shortcuts

```
Run Query:              F5 or Ctrl+Enter
New Query:              Ctrl+N
Save Query:             Ctrl+S
Format SQL:             Shift+Alt+F
Comment Line:           Ctrl+/
```

---

## 📋 Migration File Naming

### Format
```
YYYYMMDDHHMMSS_description.sql
```

### Generate Timestamp
```javascript
// In browser console:
new Date().toISOString().replace(/[-:T.Z]/g, '').slice(0, 14)
```

### Examples
```
20251117120000_add_comments.sql
20251117130000_update_permissions.sql
20251117140000_fix_storage.sql
```

---

## 🚨 Troubleshooting

| Problem | Solution |
|---------|----------|
| Can't find Supabase project | Check email for invitation, verify PROJECT_ID |
| Permission denied | Log in to correct Supabase account |
| SQL errors | Check syntax, use IF EXISTS/IF NOT EXISTS |
| Changes don't appear | Clear cache, verify correct project |
| Accidentally ran bad SQL | Use DROP TABLE/DROP COLUMN to reverse |

---

## ✅ Best Practices

```
DO:
✓ Create migration files for all changes
✓ Use descriptive file names
✓ Add IF NOT EXISTS / IF EXISTS
✓ Test SQL before running
✓ Comment your SQL
✓ Apply migrations in order

DON'T:
✗ Modify existing migration files
✗ Delete migration files
✗ Run untested SQL on production
✗ Skip migration files
```

---

## 🔗 Full Documentation

- **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** - Complete guide
- **[LOVABLE_SQL_FAQ.md](./LOVABLE_SQL_FAQ.md)** - Frequently asked questions
- **[FIX_RLS_NOW.sql](./FIX_RLS_NOW.sql)** - Ready-to-use SQL fix
- **[FIND_YOUR_SUPABASE_CONNECTION.md](./FIND_YOUR_SUPABASE_CONNECTION.md)** - Find your Supabase
- **[MIGRATION_QUICKSTART.md](./MIGRATION_QUICKSTART.md)** - CLI-based guide

---

## 💡 Quick Workflows

### One-Time Fix
```
1. Go to Supabase SQL Editor
2. Paste SQL
3. Run
```

### Version-Controlled Change
```
1. Create migration file in supabase/migrations/
2. Write SQL in file
3. Save in Lovable
4. Copy SQL
5. Run in Supabase SQL Editor
```

### Apply Existing Script
```
1. Open FIX_RLS_NOW.sql (or other .sql file)
2. Copy all
3. Paste in SQL Editor
4. Run
```

---

**Remember**: You don't need CLI to edit SQL on Lovable! Just use the Supabase SQL Editor. 🎉
