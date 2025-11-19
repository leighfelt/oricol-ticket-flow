# How to Run SQL Migrations on Lovable (Copy & Overwrite Method)

## The Problem You're Facing

You cannot access Supabase directly or run SQL commands on Lovable using the CLI. You need a way to apply SQL migrations from your GitHub repository to your Supabase database.

**This guide shows you EXACTLY how to do this! 🎉**

---

## 🚀 Quick Answer: 3 Methods to Apply Migrations on Lovable

### Method 1: Use the Built-in Migration Manager UI (Easiest) ⚡

**This is the BEST method** - Your app already has a built-in migration system!

#### How to Access It:

**Option A: Add Migration Manager to Your Dashboard**

1. **Open your Lovable project**
2. **Ask Lovable to add the MigrationManager component**:
   - Tell Lovable: "Add the MigrationManager component to the main dashboard page"
   - Or manually edit `src/pages/Dashboard.tsx` or `src/pages/Index.tsx`

3. **Import and add the component**:
   ```tsx
   import { MigrationManager } from "@/components/MigrationManager";
   
   // Inside your component's return statement:
   <MigrationManager />
   ```

4. **Once added, you'll see a card with**:
   - ✅ Number of applied migrations
   - ⚠️ Number of pending migrations
   - 🔘 Button to "Apply Migrations"

5. **Click "Apply Migrations"** - Done! ✅

**Option B: Create a Dedicated Admin/Settings Page**

If you want to keep migrations separate:

1. Create a new page: `src/pages/Settings.tsx` or `src/pages/Admin.tsx`
2. Add the `MigrationManager` component there
3. Add a link to this page in your navigation menu

#### ⚠️ Current Limitation

The `apply-migrations` Edge Function currently doesn't have the SQL content embedded. See **Method 2** below to fix this, or use **Method 3** as a workaround.

---

### Method 2: Update Edge Function to Include Migration SQL (Best Long-term Solution) 📝

This method makes the Migration Manager UI fully functional by embedding migration SQL content in the Edge Function.

#### Step 1: Update the `apply-migrations` Edge Function

Edit the file: `supabase/functions/apply-migrations/index.ts`

Replace the empty `migrationFiles` object with the actual migration content:

```typescript
// Map of migration files to their SQL content
const migrationFiles: Record<string, string> = {
  "20251108052000_bee9ee20-5a81-402a-bdd9-30cce8e8ecb7.sql": `
    -- Paste the ENTIRE content of this file here
    -- You can copy it from supabase/migrations/20251108052000_bee9ee20-5a81-402a-bdd9-30cce8e8ecb7.sql
  `,
  "20251109045855_6a7fc76b-c088-4052-a67d-5471bc1cf984.sql": `
    -- Paste the content here
  `,
  // ... add all other migrations
};
```

#### Step 2: How to Add Migration Content

For each migration file in `supabase/migrations/`:

1. **Open the migration file** (e.g., `20251108052000_bee9ee20-5a81-402a-bdd9-30cce8e8ecb7.sql`)
2. **Copy the ENTIRE SQL content**
3. **Paste it into the migrationFiles object** as shown above
4. **Repeat for all migration files**

#### Step 3: Deploy the Updated Function

On Lovable, when you save the file:
- It automatically commits to GitHub
- Lovable auto-deploys Edge Functions
- Your Migration Manager UI will now work! ✅

#### Pro Tip: Automate This

Instead of manually copying all 60+ migrations, you could:

1. **Create a script** that reads all migration files and generates the TypeScript code
2. **Or use a template literal** to load migrations dynamically from GitHub (see advanced section below)

---

### Method 3: Manual Copy & Paste to Supabase SQL Editor (Quick Workaround) 🔧

This is the manual method you can use right now without any code changes.

#### Step 1: Find Your Pending Migrations

1. **Check the `check-migrations` function** or look in `supabase/migrations/` folder
2. **Identify which migrations haven't been applied yet**
   - Compare with what's in your database's `schema_migrations` table
   - Or use the Migration Manager UI to see which are "Pending"

#### Step 2: Copy Migration SQL Content

1. **Open the migration file** in Lovable or GitHub
   - Example: `supabase/migrations/20251117102836_e9e402df-9138-41a1-874c-39dc729c3cbd.sql`
2. **Select all content** (Ctrl+A)
3. **Copy** (Ctrl+C)

#### Step 3: Apply to Supabase

1. **Go to your Supabase Dashboard**:
   - URL: `https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp`
   - Or use your own project ID

2. **Open SQL Editor**:
   - Click "SQL Editor" in the left sidebar
   - Click "New Query"

3. **Paste the migration SQL** (Ctrl+V)

4. **Run the query** (press F5 or click "Run")

5. **Verify success** - You should see "Success" at the bottom

#### Step 4: Mark as Applied (Important!)

After running the SQL, you need to record that this migration was applied:

```sql
-- Replace with your migration filename (without .sql extension)
INSERT INTO schema_migrations (version)
VALUES ('20251117102836_e9e402df-9138-41a1-874c-39dc729c3cbd')
ON CONFLICT (version) DO NOTHING;
```

Run this SQL to mark it as applied.

#### Step 5: Repeat for All Pending Migrations

- Apply migrations **in chronological order** (oldest first)
- Always mark each one as applied in the `schema_migrations` table

---

## 📋 Which File to Overwrite?

Based on your question "what file do I overwrite?" - here's the answer:

### To Enable Automatic Migration Application:

**Overwrite this file**: `supabase/functions/apply-migrations/index.ts`

**What to change**:
- Add the actual SQL content from all migration files
- See **Method 2** above for detailed instructions

### To Apply Migrations Manually:

**Don't overwrite anything!** Instead:
- Copy SQL from files in `supabase/migrations/`
- Paste into Supabase SQL Editor
- See **Method 3** above

---

## 🔍 Understanding the Migration System

### Current Setup

Your project has:

1. **Migration files** in `supabase/migrations/` (63 files)
   - These contain SQL to create tables, policies, functions, etc.

2. **Migration Manager UI** in `src/components/MigrationManager.tsx`
   - Shows which migrations are applied
   - Has a button to apply pending migrations

3. **Edge Functions**:
   - `check-migrations` - Lists which migrations are applied/pending ✅ (fully working)
   - `apply-migrations` - Should apply pending migrations ⚠️ (needs SQL content added)

4. **Database table** `schema_migrations`
   - Tracks which migrations have been applied
   - Each row = one applied migration

### How It Should Work

1. **You add a new migration file** to `supabase/migrations/` in GitHub
2. **Lovable syncs the file** from GitHub
3. **MigrationManager detects** the new migration (via `check-migrations` function)
4. **You click "Apply Migrations"** button
5. **The `apply-migrations` function**:
   - Reads the migration SQL
   - Executes it against your database
   - Records it in `schema_migrations` table
6. **Done!** ✅ Your database is updated

### What's Missing

The `apply-migrations` function doesn't have the SQL content for each migration file. You need to add it using **Method 2** above.

---

## 🛠️ Advanced: Auto-Load Migrations from GitHub

Instead of manually copying all migration SQL into the Edge Function, you can make it dynamically fetch from GitHub:

```typescript
// supabase/functions/apply-migrations/index.ts

const GITHUB_REPO = "craigfelt/oricol-ticket-flow-4084ab4c";
const MIGRATIONS_PATH = "supabase/migrations";

async function fetchMigrationContent(filename: string): Promise<string> {
  const url = `https://raw.githubusercontent.com/${GITHUB_REPO}/main/${MIGRATIONS_PATH}/${filename}`;
  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Failed to fetch ${filename} from GitHub`);
  }
  return await response.text();
}

// Then in your migration loop:
for (const filename of pendingMigrations) {
  const sql = await fetchMigrationContent(filename);
  // ... execute the SQL
}
```

This approach:
- ✅ No need to manually copy migration content
- ✅ Always uses the latest version from GitHub
- ✅ Works for new migrations automatically
- ⚠️ Requires internet access from Edge Function
- ⚠️ Slightly slower than embedded SQL

---

## 🎯 Recommended Approach

**For immediate use**: Use **Method 3** (Manual Copy & Paste)
- Fast to get started
- No code changes needed
- Good for one-time migration application

**For long-term use**: Use **Method 2** (Update Edge Function)
- Makes the UI fully functional
- One-click migration application
- Better for team collaboration

**For best experience**: Use **Method 2** + **Advanced Auto-Load**
- Fully automated
- No manual updates needed
- Scales with your project

---

## 📚 Step-by-Step Example: Applying One Migration

Let's say you want to apply migration `20251118031628_a1b4b539-b26d-419f-93d1-5a8e855ce824.sql`:

### Using Method 3 (Manual):

1. **Open the file** in Lovable:
   - Navigate to `supabase/migrations/20251118031628_a1b4b539-b26d-419f-93d1-5a8e855ce824.sql`

2. **Copy the content** (select all, Ctrl+C)

3. **Go to Supabase**:
   - Open: https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp/sql

4. **Paste and run**:
   - Click "New Query"
   - Paste the SQL
   - Press F5 or click "Run"

5. **Mark as applied**:
   ```sql
   INSERT INTO schema_migrations (version)
   VALUES ('20251118031628_a1b4b539-b26d-419f-93d1-5a8e855ce824')
   ON CONFLICT (version) DO NOTHING;
   ```
   - Run this SQL too

6. **Done!** ✅

---

## ❓ FAQ

### Q: Do I need to apply all 63 migrations?

**A:** No! Only apply migrations that haven't been applied yet.

**Check which are already applied**:
```sql
SELECT version FROM schema_migrations ORDER BY version;
```

Run this in Supabase SQL Editor to see which migrations are already done.

### Q: Can I apply multiple migrations at once?

**A:** Yes! You can:

1. **Combine the SQL** from multiple migration files
2. **Paste all at once** into SQL Editor
3. **Run together**

**Important**: 
- Apply in chronological order (oldest first)
- After running, mark each one in `schema_migrations`

### Q: What if a migration fails?

**A:** 
1. **Read the error message** - it will tell you what went wrong
2. **Common issues**:
   - Table/column already exists - use `IF NOT EXISTS`
   - Syntax error - check SQL carefully
   - Dependency error - apply earlier migrations first

3. **Fix and retry** or **skip if it's already applied**

### Q: Where is the `schema_migrations` table?

**A:** It might not exist yet! Create it:

```sql
CREATE TABLE IF NOT EXISTS schema_migrations (
  version text PRIMARY KEY,
  applied_at timestamptz DEFAULT now()
);
```

### Q: Can I use the CLI instead?

**A:** Not on Lovable's web editor. But if you:
- Clone the repo to your computer
- Have Node.js and Supabase CLI installed

Then you can use: `npm run migrate`

---

## 🔗 Related Documentation

- **[LOVABLE_SQL_EDITING_GUIDE.md](./LOVABLE_SQL_EDITING_GUIDE.md)** - General SQL editing on Lovable
- **[LOVABLE_SQL_CHEATSHEET.md](./LOVABLE_SQL_CHEATSHEET.md)** - Quick reference
- **[SUPABASE_MIGRATIONS.md](./SUPABASE_MIGRATIONS.md)** - CLI-based migration guide
- **[FIND_YOUR_SUPABASE_CONNECTION.md](./FIND_YOUR_SUPABASE_CONNECTION.md)** - How to access Supabase

---

## ✅ Summary

**Question**: How do I run SQL migrations on Lovable by copying & overwriting files?

**Answer**: You have 3 options:

1. **Use Migration Manager UI** (once you update the Edge Function)
   - File to update: `supabase/functions/apply-migrations/index.ts`
   - Add SQL content from migration files
   - Then click "Apply Migrations" in the UI

2. **Manual copy-paste** (works right now, no changes needed)
   - Copy from: `supabase/migrations/*.sql`
   - Paste into: Supabase SQL Editor
   - Mark as applied in `schema_migrations` table

3. **Auto-load from GitHub** (advanced)
   - Update Edge Function to fetch from GitHub
   - No manual copying needed
   - Fully automated

**Recommended**: Start with Manual (Method 3), then upgrade to Edge Function (Method 2) for long-term use.

---

**Last Updated**: November 2025
