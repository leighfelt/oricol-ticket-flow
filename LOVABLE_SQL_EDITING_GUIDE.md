# How to Edit SQL on Lovable Without CLI Access

## The Problem
You're working on **Lovable** and need to make database (SQL) changes, but:
- ❌ You can't run CLI commands in Lovable
- ❌ You're not sure how to access your Supabase dashboard
- ❌ The migration guides assume you can run `npm run migrate`

**This guide solves that!** 🎉

---

## Quick Answer: 3 Ways to Edit SQL on Lovable

### Option 1: Direct SQL Editor (Fastest - No CLI Needed) ⚡
**Best for**: Quick fixes, applying existing SQL scripts, one-time changes

1. **Find your Supabase dashboard** (see [Finding Your Supabase](#finding-your-supabase-dashboard) below)
2. **Open SQL Editor**: Click "SQL Editor" in the left sidebar
3. **Paste and run your SQL**:
   - Click "New Query"
   - Paste your SQL code
   - Click "Run" (or press F5)
   - ✅ Done!

**Example**: Apply the `FIX_RLS_NOW.sql` file:
- Open the file in GitHub or Lovable
- Copy all contents (Ctrl+A, Ctrl+C)
- Paste into Supabase SQL Editor
- Run it!

### Option 2: Create Migration Files in Lovable (Best Practice) 📝
**Best for**: Tracking changes, team collaboration, version control

1. **In Lovable**, navigate to `supabase/migrations/` folder
2. **Create a new file** with the naming pattern:
   ```
   YYYYMMDDHHMMSS_description.sql
   ```
   Example: `20251117120000_add_new_column.sql`
   
3. **Write your SQL** in the file:
   ```sql
   -- Add a new column to the tickets table
   ALTER TABLE public.tickets ADD COLUMN IF NOT EXISTS custom_field text;
   ```

4. **Save the file** in Lovable (it auto-commits to GitHub)

5. **Apply the migration** using the Supabase SQL Editor:
   - Go to your Supabase dashboard
   - Open SQL Editor
   - Copy the contents of your new migration file
   - Paste and run in SQL Editor
   - ✅ Changes applied!

6. **Record in migration history** (optional but recommended):
   - Go to Supabase → Database → Migrations
   - The changes will be tracked in your database

### Option 3: Edit via GitHub (Alternative) 🌐
**Best for**: When Lovable editor is unavailable

1. **Go to your GitHub repository**:
   ```
   https://github.com/craigfelt/oricol-ticket-flow-34e64301
   ```

2. **Navigate to** `supabase/migrations/`

3. **Create new file** (click "Add file" → "Create new file"):
   - Name it: `YYYYMMDDHHMMSS_your_change.sql`
   - Write your SQL
   - Commit the file

4. **Lovable auto-syncs** from GitHub (usually within minutes)

5. **Apply via Supabase SQL Editor** (same as Option 2, step 5)

---

## Finding Your Supabase Dashboard

### Step 1: Find Your Project ID

**In Lovable:**
1. Open your Lovable project
2. Go to **Settings** → **Environment Variables**
3. Look for `VITE_SUPABASE_PROJECT_ID`
4. Copy the value (e.g., `kwmeqvrmtivmljujwocp`)

**Or in the code:**
1. Open `supabase/config.toml` in Lovable
2. Find the line: `project_id = "..."`
3. Copy the project ID

**Or check `.env`:**
1. Open `.env` file in Lovable
2. Find `VITE_SUPABASE_PROJECT_ID=...`
3. Copy the value

### Step 2: Access Your Supabase Dashboard

**Direct URL:**
```
https://supabase.com/dashboard/project/[YOUR_PROJECT_ID]
```

Example for this project:
```
https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp
```

**Or navigate manually:**
1. Go to https://supabase.com/dashboard
2. Log in with your Supabase account
3. Look for your project (match the Project ID)
4. Click to open it

### Step 3: What if the Project Doesn't Exist?

If you don't see the project in your Supabase dashboard:

**Scenario A: Lovable Auto-Provisioned**
- Lovable may have created a Supabase project for you
- Check your email for a Supabase invitation
- Accept the invitation to gain access

**Scenario B: Need to Create Your Own**
1. Go to https://supabase.com/dashboard
2. Click "New Project"
3. Create a free project
4. Copy the project details
5. Update Lovable environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`
   - `VITE_SUPABASE_PROJECT_ID`
6. Apply all migrations from `supabase/migrations/` in order

---

## Common SQL Tasks (No CLI Required)

### Task 1: Fix "Row Level Security" Errors

**Problem**: Getting "new row violates row-level security policy" when uploading files

**Solution**:
1. Open the `FIX_RLS_NOW.sql` file in Lovable or GitHub
2. Copy the entire contents
3. Go to Supabase → SQL Editor
4. Paste and click "Run"
5. ✅ Fixed!

### Task 2: Add a New Table

**Create the migration file**:
```sql
-- File: supabase/migrations/20251117120000_add_my_table.sql

CREATE TABLE IF NOT EXISTS public.my_new_table (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  name text NOT NULL,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Enable Row Level Security
ALTER TABLE public.my_new_table ENABLE ROW LEVEL SECURITY;

-- Create a policy
CREATE POLICY "Users can view their own records"
  ON public.my_new_table FOR SELECT
  TO authenticated
  USING (auth.uid() = id);
```

**Apply it**:
1. Save the file in Lovable (in `supabase/migrations/`)
2. Copy the contents
3. Paste into Supabase SQL Editor
4. Run it

### Task 3: Modify Existing Table

**Create the migration file**:
```sql
-- File: supabase/migrations/20251117130000_modify_tickets.sql

-- Add a new column
ALTER TABLE public.tickets 
  ADD COLUMN IF NOT EXISTS priority_score integer DEFAULT 0;

-- Add an index for performance
CREATE INDEX IF NOT EXISTS idx_tickets_priority_score 
  ON public.tickets(priority_score);
```

**Apply it**: Same as Task 2

### Task 4: Update Row Level Security Policies

**Create the migration file**:
```sql
-- File: supabase/migrations/20251117140000_update_rls.sql

-- Drop old policy
DROP POLICY IF EXISTS "Users can view tickets" ON public.tickets;

-- Create new policy
CREATE POLICY "Users can view all tickets"
  ON public.tickets FOR SELECT
  TO authenticated
  USING (true);
```

**Apply it**: Same as Task 2

### Task 5: Add/Update Storage Buckets

**Create the migration file**:
```sql
-- File: supabase/migrations/20251117150000_add_storage.sql

-- Create a new storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit)
VALUES (
  'my-files',
  'my-files',
  true,
  104857600  -- 100MB
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit;

-- Add storage policies
CREATE POLICY "Authenticated users can upload"
  ON storage.objects FOR INSERT
  TO authenticated
  WITH CHECK (bucket_id = 'my-files');

CREATE POLICY "Public can view"
  ON storage.objects FOR SELECT
  TO public
  USING (bucket_id = 'my-files');
```

**Apply it**: Same as Task 2

---

## Migration File Naming Convention

When creating migration files, use this format:
```
YYYYMMDDHHMMSS_description.sql
```

**How to generate the timestamp:**

**Option 1: Use Current Date/Time**
- Get current UTC time
- Format: Year (4 digits) + Month (2) + Day (2) + Hour (2) + Minute (2) + Second (2)
- Example: `20251117153045` = November 17, 2025 at 15:30:45 UTC

**Option 2: Use a Tool**
- Online: Search "unix timestamp converter" and convert to YYYYMMDDHHMMSS format
- JavaScript console: `new Date().toISOString().replace(/[-:T.Z]/g, '').slice(0, 14)`

**Examples:**
```
20251117120000_add_comments_table.sql
20251117130000_update_user_permissions.sql
20251117140000_fix_storage_policies.sql
```

**Important**: Always use a timestamp that's later than existing migrations!

---

## Workflow: Making Database Changes on Lovable

### Full Workflow (Best Practice)

```
1. Decide what SQL changes you need
   └→ Write SQL locally or in a text editor

2. Create migration file in Lovable
   └→ Navigate to supabase/migrations/
   └→ Create: YYYYMMDDHHMMSS_description.sql
   └→ Paste your SQL
   └→ Save (auto-commits to GitHub)

3. Apply changes to Supabase
   └→ Open Supabase dashboard
   └→ Go to SQL Editor
   └→ Copy migration file contents
   └→ Paste and Run

4. Verify changes worked
   └→ Check Tables in Supabase
   └→ Test in your app
   └→ ✅ Done!
```

### Quick Workflow (For One-Time Fixes)

```
1. Open Supabase SQL Editor
   
2. Write/paste your SQL directly
   
3. Run it
   
4. (Optional) Save to a migration file for version control
```

---

## Troubleshooting

### "I can't find my Supabase project"

**Solution**:
1. Check your email for Supabase invitation
2. Check Lovable environment variables for `VITE_SUPABASE_PROJECT_ID`
3. See the [Finding Your Supabase](#finding-your-supabase-dashboard) section above
4. See `FIND_YOUR_SUPABASE_CONNECTION.md` for detailed help

### "I get permission denied in SQL Editor"

**Solution**:
- Make sure you're logged in to the correct Supabase account
- Verify you have access to the project (check invitations)
- Contact Lovable support if it's an auto-provisioned project

### "My SQL has errors when I run it"

**Solution**:
1. Check for syntax errors (missing semicolons, typos)
2. Check if the table/column already exists
3. Look at the error message for clues
4. Try running parts of the SQL separately to isolate the issue

### "Changes don't appear in my app"

**Possible causes**:
1. **Wrong Supabase project** - Verify your app is using the correct project ID
2. **Cache** - Clear browser cache and refresh
3. **SQL didn't run** - Check Supabase logs for errors
4. **App not redeployed** - Changes to SQL don't require redeployment, but check anyway

### "I accidentally ran bad SQL"

**Solution**:
1. **Don't panic!** Most changes can be reversed
2. **For added columns**: 
   ```sql
   ALTER TABLE table_name DROP COLUMN column_name;
   ```
3. **For added tables**: 
   ```sql
   DROP TABLE IF EXISTS table_name;
   ```
4. **For policies**:
   ```sql
   DROP POLICY IF EXISTS "policy_name" ON table_name;
   ```
5. **For data changes**: You may need to restore from a backup
6. **Prevention**: Always test SQL on a development project first!

---

## Best Practices

✅ **DO**:
- Create migration files for all changes (for version control)
- Use descriptive migration file names
- Test SQL in a development environment first
- Comment your SQL to explain what it does
- Keep migrations small and focused
- Use `IF NOT EXISTS` / `IF EXISTS` for safety
- Back up important data before major changes

❌ **DON'T**:
- Don't modify existing migration files (create new ones instead)
- Don't delete migration files (they're history)
- Don't run untested SQL on production
- Don't skip migration files (apply them in order)
- Don't hardcode values (use variables when possible)

---

## Quick Reference

### Essential Files
```
FIX_RLS_NOW.sql              - Fix storage/upload errors (run in SQL Editor)
supabase/migrations/         - All migration files (version controlled)
supabase/config.toml         - Project configuration (contains project_id)
.env                         - Environment variables (local only)
```

### Essential Links
```
Supabase Dashboard:          https://supabase.com/dashboard
Your Project Dashboard:      https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp
SQL Editor:                  https://supabase.com/dashboard/project/[PROJECT_ID]/sql
GitHub Repo:                 https://github.com/craigfelt/oricol-ticket-flow-34e64301
Lovable Project:             https://lovable.dev/projects/c75c70a7-c13d-4879-a8af-bbb8cc076141
```

### Common SQL Editor Shortcuts
```
Run Query:                   F5 or Ctrl+Enter
New Query:                   Ctrl+N
Save Query:                  Ctrl+S
Format SQL:                  Shift+Alt+F
```

---

## 📚 Related Documentation

- **LOVABLE_MIGRATION_GUIDE.md** - **How to run migrations on Lovable (copy & overwrite method)**
- **FIND_YOUR_SUPABASE_CONNECTION.md** - How to find and access your Supabase project
- **MIGRATION_QUICKSTART.md** - Quick guide for running migrations with CLI
- **SUPABASE_MIGRATIONS.md** - Complete migration guide (CLI-focused)
- **FIX_RLS_NOW.sql** - Ready-to-use SQL fix for storage errors
- **QUICKFIX_START_HERE.md** - Quick fix for common RLS errors
- **LOVABLE_SQL_FAQ.md** - Frequently asked questions

---

## Summary

**You don't need CLI access to edit SQL on Lovable!**

**The simplest workflow:**
1. Find your Supabase dashboard (see above)
2. Go to SQL Editor
3. Write or paste your SQL
4. Run it
5. (Optional) Save to a migration file in `supabase/migrations/` for version control

**The best-practice workflow:**
1. Create migration file in Lovable: `supabase/migrations/YYYYMMDDHHMMSS_description.sql`
2. Write your SQL in the file
3. Save (auto-commits to GitHub)
4. Copy the SQL and run in Supabase SQL Editor
5. ✅ Changes applied and tracked!

**Need help?** See the troubleshooting section above or the related documentation files.

---

**Last Updated**: November 2025
