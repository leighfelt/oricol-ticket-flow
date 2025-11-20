# 🚀 Automated Migration Helper - Quick Start Guide

This guide will help you automatically detect and apply all pending Supabase migrations using the new CLI helper scripts.

## 📋 Quick Commands

```bash
# Check migration status (see what's pending)
npm run migrate:status

# Run the automated migration helper
npm run migrate

# Dry run to preview (doesn't make changes)
npm run migrate -- --dry-run
```

## 🎯 Step-by-Step Usage

### 1️⃣ Check Current Status

First, see which migrations are pending:

```bash
npm run migrate:status
```

**Example Output:**
```
Migration Status Report
═══════════════════════════════════════════════

📁 Total migrations found: 82

✅ Applied migrations: 78
⏳ Pending migrations: 4

Migration Status:

  1. ✓ Applied 20251100000000_create_schema_migrations_table.sql
  ...
  79. ⏳ Pending 20251119034817_new_feature.sql
  80. ⏳ Pending 20251119050102_security_update.sql
  ...
```

### 2️⃣ Run Migration Helper

The automated helper will detect all pending migrations:

```bash
npm run migrate
```

**What it does:**
- ✅ Scans `supabase/migrations/` directory
- ✅ Checks which migrations are already applied
- ✅ Lists pending migrations in chronological order
- ✅ Shows you exactly what needs to be applied

### 3️⃣ Apply Migrations

The script will guide you through applying migrations using one of these methods:

#### **Option A: In-App Migration Manager** ⭐ Recommended

1. Navigate to `/settings` in your application
2. Scroll to the "Migrations" section
3. Click "Apply Migration" for each pending migration

#### **Option B: Supabase CLI**

If you have Supabase CLI installed:

```bash
npx supabase db push
```

#### **Option C: SQL Editor**

1. Open your Backend dashboard (Lovable Cloud)
2. Go to SQL Editor
3. Copy and paste the SQL from each migration file
4. Execute them in order

## 🎨 Features

### Automatic Detection
- Scans your migrations directory
- Identifies applied vs pending migrations
- Sorts migrations chronologically

### Safety First
- **Dry run mode** to preview changes without applying
- **Force mode** for re-applying migrations (use carefully!)
- **Order enforcement** to prevent out-of-sequence application

### Clear Output
- Color-coded status indicators
- Detailed migration lists
- SQL preview for manual application

## 💡 Advanced Usage

### Dry Run (Preview Only)

See what would be applied without making any changes:

```bash
npm run migrate -- --dry-run
```

**Example Output:**
```
🔍 Running in DRY RUN mode - no changes will be made

[DRY RUN] Would apply: 20251119034817_new_feature.sql
[DRY RUN] Would apply: 20251119050102_security_update.sql
```

### Force Re-apply All

⚠️ **Use with caution!** This will mark all migrations as pending:

```bash
npm run migrate -- --force
```

## 📊 Understanding the Output

### Status Indicators

- `✓ Applied` - Migration has been successfully applied
- `⏳ Pending` - Migration needs to be applied
- `✅` - Success indicator
- `⚠️` - Warning or attention needed
- `❌` - Error or failure

### Color Coding

- **Green** - Success / Applied
- **Yellow** - Pending / Warning
- **Red** - Error / Failed
- **Blue** - Info / Action required
- **Cyan** - Headings / Titles
- **Gray** - Supporting text

## 🔧 Troubleshooting

### Problem: "Missing Supabase credentials"

**Solution:** Ensure your `.env` file contains:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key-here
```

### Problem: "schema_migrations table does not exist"

**Solution:** This is normal on first run. The first migration creates this table. Apply migrations using one of the three methods above.

### Problem: Migrations showing as pending but already applied

**Solution:** The `schema_migrations` table might not have been updated. Check the table manually:

```sql
SELECT * FROM schema_migrations ORDER BY applied_at DESC;
```

### Problem: Can't execute SQL from script

**Solution:** This is by design for security. The script detects and guides you, but you must apply migrations using:
- In-app Migration Manager (recommended)
- Supabase CLI
- SQL Editor

## 📝 Best Practices

1. **Always check status first**
   ```bash
   npm run migrate:status
   ```

2. **Use dry run to preview**
   ```bash
   npm run migrate -- --dry-run
   ```

3. **Apply migrations in order**
   - Never skip migrations
   - They build on each other

4. **Backup before production**
   - Always backup production data
   - Test on development first

5. **Commit migrations to git**
   - Track migration files
   - Document changes

## 🎓 Examples

### Example 1: First-Time Setup

```bash
# Check what needs to be applied
$ npm run migrate:status
📁 Total migrations found: 82
✅ Applied migrations: 0
⏳ Pending migrations: 82

# Run migration helper
$ npm run migrate
Found 82 migration files
Listing all pending migrations...

# Then apply using in-app manager or CLI
```

### Example 2: After Creating New Migration

```bash
# Create new migration in the app
# Migration saved: 20251120120000_add_new_table.sql

# Check status
$ npm run migrate:status
⏳ Pending migrations: 1

# Apply using migration manager
Navigate to /settings → Apply the new migration
```

### Example 3: Checking Migration History

```bash
$ npm run migrate:status

Migration Status:

  1. ✓ Applied 20251100000000_create_schema_migrations_table.sql
  2. ✓ Applied 20251108052000_bee9ee20-5a81-402a-bdd9-30cce8e8ecb7.sql
  3. ✓ Applied 20251109045855_6a7fc76b-c088-4052-a67d-5471bc1cf984.sql
  ...
  80. ✓ Applied 20251119050102_87ec93cb-5d13-4ff1-bc63-02721e798d75.sql
  81. ⏳ Pending 20251120120000_add_new_table.sql

✅ All but 1 migration applied!
```

## 🔗 Integration with Workflow

### Development Workflow

1. **Create migration** in the app using migration tool
2. **Check status** with `npm run migrate:status`
3. **Review SQL** in migration file
4. **Apply** using preferred method
5. **Verify** with another status check
6. **Commit** migration file to git

### CI/CD Integration

You can integrate these scripts into your CI/CD pipeline:

```yaml
# Example GitHub Actions step
- name: Check migrations
  run: npm run migrate:status
  
- name: Detect pending migrations
  run: npm run migrate -- --dry-run
```

## 📚 Additional Resources

- [Supabase Migrations Documentation](https://supabase.com/docs/guides/cli/local-development#database-migrations)
- [In-App Migration Manager](/settings)
- [Backend SQL Editor](https://supabase.com/dashboard/project/_/sql)

## 🆘 Need Help?

If you encounter issues:

1. Check this guide first
2. Review the troubleshooting section
3. Check migration files for SQL errors
4. Verify Supabase credentials
5. Contact support with error details

---

**Happy migrating! 🚀**
