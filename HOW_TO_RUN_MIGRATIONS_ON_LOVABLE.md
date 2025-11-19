# ⚡ Quick Answer: How to Run SQL Migrations on Lovable

## Your Question
> I cannot access supabase direct or run sql on lovable. I need a way to run the sql migration on lovable by copying & overwriting files - how do i do this - what file do I overwrite?

## 🎯 Direct Answer

### Option 1: Use the Built-in Migration Manager (Recommended)

**File to Update**: `supabase/functions/apply-migrations/index.ts`

✅ **Already Done!** - This file has been updated to automatically fetch and apply migrations from GitHub.

**How to Use It**:

1. **Add MigrationManager to your dashboard**:
   - Edit `src/pages/Dashboard.tsx` or `src/pages/Index.tsx`
   - Add this import: `import { MigrationManager } from "@/components/MigrationManager";`
   - Add the component: `<MigrationManager />`

2. **In your Lovable app**:
   - You'll see a "Database Migrations" card
   - It shows pending migrations
   - Click "Apply Migrations" button
   - Done! ✅

### Option 2: Manual Copy & Paste (Works Right Now)

**Files to Copy From**: `supabase/migrations/*.sql`

**Where to Paste**: Supabase SQL Editor

**Steps**:

1. **Open migration file** in `supabase/migrations/` (e.g., `20251118031628_a1b4b539-b26d-419f-93d1-5a8e855ce824.sql`)

2. **Copy entire content** (Ctrl+A, Ctrl+C)

3. **Go to Supabase**:
   - URL: https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp/sql
   - Click "New Query"

4. **Paste and run** (Ctrl+V, then F5)

5. **Mark as applied**:
   ```sql
   INSERT INTO schema_migrations (version)
   VALUES ('20251118031628_a1b4b539-b26d-419f-93d1-5a8e855ce824')
   ON CONFLICT (version) DO NOTHING;
   ```

6. **Done!** ✅

## 📋 Summary Table

| What You Want | File to Overwrite/Update | What It Does |
|---------------|-------------------------|--------------|
| **Automatic UI-based migrations** | `supabase/functions/apply-migrations/index.ts` | ✅ Already updated! Fetches migrations from GitHub and applies them |
| **Add migration UI to app** | `src/pages/Dashboard.tsx` or similar | Add `<MigrationManager />` component |
| **Manual migration (no file changes)** | None - just copy from `supabase/migrations/*.sql` | Paste into Supabase SQL Editor |

## 🔑 Key Points

1. **You don't need to overwrite anything** to run migrations manually - just copy SQL and paste into Supabase SQL Editor

2. **To enable automatic migrations**, the file `supabase/functions/apply-migrations/index.ts` has already been updated for you

3. **To use the automatic system**, add the `MigrationManager` component to your UI

4. **Your Supabase project ID**: `kwmeqvrmtivmljujwocp`

5. **Your Supabase SQL Editor**: https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp/sql

## 📚 For More Details

See **[LOVABLE_MIGRATION_GUIDE.md](./LOVABLE_MIGRATION_GUIDE.md)** for:
- Complete step-by-step instructions
- All available methods
- Troubleshooting
- Advanced options
- FAQ

---

**Last Updated**: November 2025
