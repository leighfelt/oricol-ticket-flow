# FAQ: Editing SQL on Lovable

Frequently asked questions about editing SQL and managing database changes when working on Lovable.

---

## ❓ Common Questions

### Q: Can I edit SQL on Lovable without using the CLI?

**A: Yes!** You can edit SQL directly through the Supabase SQL Editor. 

See: **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** for complete instructions.

---

### Q: How do I find my Supabase dashboard?

**A:** There are several ways:

1. **Direct URL** (for this project):
   ```
   https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp
   ```

2. **Find your project ID:**
   - In Lovable: Settings → Environment Variables → `VITE_SUPABASE_PROJECT_ID`
   - Or check: `supabase/config.toml` → `project_id = "..."`
   - Then go to: `https://supabase.com/dashboard/project/[PROJECT_ID]`

3. **See:** [FIND_YOUR_SUPABASE_CONNECTION.md](./FIND_YOUR_SUPABASE_CONNECTION.md) for detailed steps

---

### Q: Do I need to run `npm run migrate` on Lovable?

**A: No!** That command requires CLI access which isn't available in Lovable's web editor.

**Instead:**
1. Copy the SQL from migration files in `supabase/migrations/`
2. Paste into Supabase SQL Editor
3. Run it

See: **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** for details.

---

### Q: How do I fix "new row violates row-level security policy" errors?

**A:** This is a common error when uploading files. Here's the quick fix:

1. Open **[FIX_RLS_NOW.sql](./FIX_RLS_NOW.sql)** file
2. Copy all contents
3. Paste into Supabase SQL Editor
4. Run it (press F5)
5. ✅ Fixed!

See: **[QUICKFIX_START_HERE.md](./QUICKFIX_START_HERE.md)** for step-by-step instructions.

---

### Q: How do I create a new migration file?

**A:** In Lovable:

1. Navigate to `supabase/migrations/` folder
2. Create new file with format: `YYYYMMDDHHMMSS_description.sql`
   - Example: `20251117120000_add_column.sql`
3. Write your SQL in the file
4. Save (Lovable auto-commits to GitHub)
5. Copy the SQL and run in Supabase SQL Editor

See: **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** → "Task 2: Add a New Table"

---

### Q: What's the timestamp format for migration files?

**A:** `YYYYMMDDHHMMSS_description.sql`

**Example:** `20251117153045_add_new_feature.sql`

**Generate timestamp:**
- JavaScript console: 
  ```javascript
  new Date().toISOString().replace(/[-:T.Z]/g, '').slice(0, 14)
  ```
- Or use current date/time in UTC: Year(4) + Month(2) + Day(2) + Hour(2) + Minute(2) + Second(2)

See: **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** → "Migration File Naming Convention"

---

### Q: Can I edit SQL files directly in Lovable?

**A: Yes!** You can:
- View migration files in `supabase/migrations/`
- Create new migration files
- Edit existing SQL (though it's better to create new migrations)
- Save changes (auto-commits to GitHub)

However, **you still need to apply the SQL** in the Supabase SQL Editor for changes to take effect.

---

### Q: Where is the SQL Editor in Supabase?

**A:** 

1. Go to your Supabase dashboard
2. Look in the left sidebar
3. Click **"SQL Editor"**
4. Click **"New Query"** button
5. Paste your SQL and click **"Run"** (or press F5)

Direct link format: `https://supabase.com/dashboard/project/[PROJECT_ID]/sql`

---

### Q: Do I need to create migration files or can I just run SQL directly?

**A:** It depends:

**For one-time fixes or quick changes:**
- ✅ Just run SQL directly in SQL Editor
- No need to create migration file

**For features, schema changes, or collaborative work:**
- ✅ Create migration file in `supabase/migrations/`
- ✅ Then run the SQL
- This tracks changes in version control

**Best practice:** Always create migration files for any schema changes.

---

### Q: I don't see my Supabase project in the dashboard. Why?

**A:** Possible reasons:

1. **Lovable auto-provisioned it:**
   - Check email for Supabase invitation
   - Accept invitation to gain access

2. **Wrong account:**
   - Make sure you're logged in to the correct Supabase account
   - Check which email was used to create the project

3. **Need to create your own:**
   - Create new project at https://supabase.com
   - Update Lovable environment variables with new project details

See: **[FIND_YOUR_SUPABASE_CONNECTION.md](./FIND_YOUR_SUPABASE_CONNECTION.md)** for troubleshooting.

---

### Q: What if I accidentally run bad SQL?

**A:** Don't panic! Most changes can be reversed:

**Added a column?**
```sql
ALTER TABLE table_name DROP COLUMN column_name;
```

**Added a table?**
```sql
DROP TABLE IF EXISTS table_name;
```

**Added a policy?**
```sql
DROP POLICY IF EXISTS "policy_name" ON table_name;
```

**Changed data?**
- You may need to restore from backup
- Or manually update the data back

**Prevention:** Always test on a development database first!

---

### Q: Can I test SQL changes before applying them to production?

**A: Yes!** Best practices:

1. **Create a development Supabase project** (free tier)
2. **Apply migrations there first**
3. **Test in your app** with development environment
4. **Once verified, apply to production**

Or:

1. **Use transactions** in SQL Editor:
   ```sql
   BEGIN;
   -- Your SQL here
   -- Check results
   ROLLBACK;  -- If not good
   -- or
   COMMIT;    -- If good
   ```

---

### Q: How do I apply multiple migration files at once?

**A:** 

**Option 1: Combine them**
1. Open all migration files you need
2. Copy all SQL in order (oldest to newest)
3. Paste all into SQL Editor
4. Run once

**Option 2: Apply one by one**
1. Apply oldest migration first
2. Verify it worked
3. Apply next one
4. Repeat

**Important:** Always apply migrations in chronological order!

---

### Q: What's the difference between the `documents` and `diagrams` storage buckets?

**A:**

- **documents** bucket: For document uploads (PDF, Word, Excel, etc.)
- **diagrams** bucket: For image uploads (PNG, JPEG, etc.)

Both are created by the `FIX_RLS_NOW.sql` script.

See: **[FIX_RLS_NOW.sql](./FIX_RLS_NOW.sql)** for details.

---

### Q: How do I check if my SQL ran successfully?

**A:** In Supabase SQL Editor:

1. **Look for "Success" message** at the bottom
2. **Check the results panel** for any output
3. **Verify in the Table Editor:**
   - Go to "Table Editor" in sidebar
   - Check if your changes are there
4. **Run a verification query:**
   ```sql
   -- Check if table exists
   SELECT * FROM information_schema.tables 
   WHERE table_name = 'your_table_name';
   
   -- Check if column exists
   SELECT * FROM information_schema.columns 
   WHERE table_name = 'your_table' 
   AND column_name = 'your_column';
   ```

---

### Q: Where can I find examples of SQL for common tasks?

**A:** Check these resources:

1. **Existing migration files** in `supabase/migrations/` - lots of examples!
2. **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** → "Common SQL Tasks"
3. **[LOVABLE_SQL_CHEATSHEET.md](./LOVABLE_SQL_CHEATSHEET.md)** → "Common Tasks"
4. **Supabase docs:** https://supabase.com/docs/guides/database

---

### Q: Can I use the Supabase CLI from Lovable?

**A: No.** Lovable's web editor doesn't provide terminal/CLI access.

**But you don't need it!** Everything can be done through:
- Supabase SQL Editor (for running SQL)
- Lovable file editor (for creating migration files)
- GitHub (alternative to Lovable for editing files)

---

### Q: How do I undo a migration?

**A:** Migrations are typically forward-only. To "undo":

1. **Create a new migration** that reverses the changes
   - If you added a column, create migration to drop it
   - If you added a table, create migration to drop it
2. **Apply the new migration**
3. **Don't delete the original migration file** - keep it for history

**Example:**
```sql
-- Original: 20251117120000_add_column.sql
ALTER TABLE users ADD COLUMN phone text;

-- Reversal: 20251117130000_remove_phone_column.sql
ALTER TABLE users DROP COLUMN phone;
```

---

### Q: What are RLS policies and why do I need them?

**A:** RLS = Row Level Security

**What they do:**
- Control who can read/write data in your tables
- Protect your data from unauthorized access
- Required by Supabase for security

**Common policies:**
```sql
-- Allow authenticated users to read all
CREATE POLICY "allow_read" ON table_name
  FOR SELECT TO authenticated USING (true);

-- Allow users to edit only their own data
CREATE POLICY "allow_own" ON table_name
  FOR ALL TO authenticated
  USING (user_id = auth.uid());
```

See migration files for more examples.

---

### Q: I'm getting SQL syntax errors. What should I check?

**A:** Common mistakes:

1. **Missing semicolons** - Each SQL statement needs `;` at the end
2. **Wrong quotes** - Use single quotes `'` for values, not double `"`
3. **Reserved keywords** - Don't name columns `user`, `table`, etc.
4. **Missing IF EXISTS/IF NOT EXISTS** - Add these for safety
5. **Case sensitivity** - Table/column names may be case-sensitive

**Tip:** Run each statement separately to isolate the error.

---

### Q: How do I get help if I'm stuck?

**A:** 

1. **Check the documentation:**
   - [LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)
   - [LOVABLE_SQL_CHEATSHEET.md](./LOVABLE_SQL_CHEATSHEET.md)
   - [LOVABLE_START_HERE.md](./LOVABLE_START_HERE.md)

2. **Look at existing migrations** in `supabase/migrations/` for examples

3. **Check Supabase docs:** https://supabase.com/docs

4. **Ask in communities:**
   - Lovable community/support
   - Supabase Discord: https://discord.supabase.com

5. **Search for similar issues** on GitHub/Stack Overflow

---

## 📚 Quick Links

- **[LOVABLE_START_HERE.md](./LOVABLE_START_HERE.md)** - Start here!
- **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** - Complete guide
- **[LOVABLE_SQL_CHEATSHEET.md](./LOVABLE_SQL_CHEATSHEET.md)** - Quick reference
- **[FIX_RLS_NOW.sql](./FIX_RLS_NOW.sql)** - Fix upload errors
- **[FIND_YOUR_SUPABASE_CONNECTION.md](./FIND_YOUR_SUPABASE_CONNECTION.md)** - Find your Supabase

---

**Last Updated**: November 2025
