# Migration Manager Guide

## Overview

The Migration Manager is a powerful tool built into the Oricol Helpdesk dashboard that allows you to apply database migrations directly from the web interface without needing command-line access.

## How It Works

### Architecture

1. **Migration Files**: All database schema changes are stored as SQL files in `supabase/migrations/`
2. **Check Migrations**: The `check-migrations` edge function compares the list of migration files with those already applied to your database
3. **Apply Migrations**: The `apply-migrations` edge function fetches SQL content from GitHub and executes it on your database
4. **Migration Manager UI**: A React component on the dashboard displays migration status and provides a button to apply pending migrations

### Key Components

#### 1. Migration Files (`supabase/migrations/*.sql`)
- Timestamped SQL files containing schema changes
- Automatically tracked by the system
- RLS (Row Level Security) policies
- Table structure changes
- Function definitions
- Storage bucket configurations

#### 2. Edge Functions

**check-migrations** (`supabase/functions/check-migrations/index.ts`)
- Queries the `schema_migrations` table to see which migrations have been applied
- Returns a list of all migrations with their status (applied/pending)
- Fast and lightweight - only checks status, doesn't execute SQL

**apply-migrations** (`supabase/functions/apply-migrations/index.ts`)
- Fetches SQL content from GitHub repository
- Executes pending migrations using the `exec()` database function
- Records successful migrations in the `schema_migrations` table
- Returns detailed results including any errors

#### 3. Database Function

**exec()** (`20251118103000_create_exec_sql_function.sql`)
- A PostgreSQL function that executes arbitrary SQL
- `SECURITY DEFINER` ensures it runs with proper privileges
- Only accessible via service role (edge functions)
- Enables programmatic migration execution

#### 4. UI Component

**MigrationManager** (`src/components/MigrationManager.tsx`)
- Displays migration statistics (applied vs pending)
- Shows detailed list of all migrations
- Provides "Apply Migrations" button
- Real-time status updates

## Using the Migration Manager

### Accessing the Migration Manager

1. Log in to the Oricol Helpdesk dashboard
2. Navigate to the **Dashboard** page (default landing page)
3. You'll see the **Database Migrations** card in the Overview tab

### Checking Migration Status

The Migration Manager automatically checks for pending migrations when you load the dashboard. You can also:

1. Click the **Refresh** button to manually check for new migrations
2. Review the statistics:
   - **Applied**: Number of migrations already in your database
   - **Pending**: Number of migrations waiting to be applied

### Applying Pending Migrations

When you see pending migrations:

1. Review the list of pending migrations
2. Click the **Apply X Migration(s)** button
3. Wait for the process to complete (you'll see a loading spinner)
4. A success message will appear when complete
5. The migration list will refresh automatically

### Understanding Migration Names

Migration files follow this naming convention:
```
YYYYMMDDHHMMSS_description.sql
```

Examples:
- `20251113232600_comprehensive_rls_fix.sql` - Applied on 2025-11-13 at 23:26:00
- `20251118103000_create_exec_sql_function.sql` - Applied on 2025-11-18 at 10:30:00

The timestamp ensures migrations are applied in the correct order.

## Technical Details

### How Migrations Are Applied

1. **Fetch Migration List**: Check which migrations are already applied
   ```typescript
   const { data: appliedMigrations } = await supabase
     .from('schema_migrations')
     .select('version');
   ```

2. **Identify Pending Migrations**: Compare with the full list
   ```typescript
   const pendingMigrations = ALL_MIGRATIONS.filter(
     filename => !appliedVersions.has(filename.replace('.sql', ''))
   );
   ```

3. **Fetch SQL from GitHub**: Get the migration file content
   ```typescript
   const url = `https://raw.githubusercontent.com/${GITHUB_OWNER}/${GITHUB_REPO}/main/${MIGRATIONS_PATH}/${filename}`;
   const sql = await fetch(url).then(r => r.text());
   ```

4. **Execute SQL**: Run the migration via exec() function
   ```typescript
   await supabase.rpc('exec', { sql });
   ```

5. **Record Success**: Mark migration as applied
   ```typescript
   await supabase.from('schema_migrations').insert({ version });
   ```

### Security Considerations

#### Why is this secure?

1. **Service Role Only**: Edge functions use the service role key, which is never exposed to the client
2. **GitHub Repository**: Migrations are fetched from your own GitHub repository
3. **No User Input**: Migration SQL comes from trusted sources (your repo), not user input
4. **Audit Trail**: All applied migrations are recorded in `schema_migrations` table
5. **Idempotent**: Migrations are only applied once (tracked by version)

#### What could go wrong?

- **Network Issues**: If GitHub is down, migrations can't be fetched
- **Malformed SQL**: If a migration has syntax errors, it will fail gracefully
- **Dependencies**: If migrations are applied out of order, they may fail
- **Conflicts**: If you manually edit the database, migrations may conflict

## RLS Security Migrations

### What are RLS Security Migrations?

RLS (Row Level Security) migrations implement security policies that:
- Control who can read data (SELECT)
- Control who can write data (INSERT/UPDATE/DELETE)
- Prevent unauthorized access to sensitive information
- Ensure users can only see their own data (or data they're authorized to see)

### Key RLS Migrations in This Project

1. **20251113232600_comprehensive_rls_fix.sql**
   - Comprehensive fix for document and diagram storage policies
   - Cleans up duplicate/conflicting policies
   - Ensures consistent security across all tables

2. **20251115133000_verify_and_fix_lovable_rls.sql**
   - Verifies and fixes RLS policies created via Lovable
   - Ensures all tables have proper security

3. **20251113153200_fix_documents_table_rls_policies.sql**
   - Fixes RLS policies on the documents table
   - Ensures authenticated users can upload/manage documents

4. **20251112204108_remove_role_based_rls_policies.sql**
   - Removes overly restrictive role-based policies
   - Simplifies security model for better usability

### Data Exposure Issues Fixed

These migrations address several data exposure vulnerabilities:

1. **Public Access to Storage**: Without proper RLS, anyone could access uploaded files
2. **Cross-User Data Leakage**: Users could see other users' documents without RLS
3. **Unauthorized Modifications**: Users could modify data they shouldn't have access to
4. **Missing Policies**: Tables without RLS policies are completely unprotected

## Troubleshooting

### "Failed to check migration status"

**Cause**: The `check-migrations` edge function couldn't connect to the database or the `schema_migrations` table doesn't exist.

**Solution**:
1. Ensure your Supabase project is running
2. Check that the database is accessible
3. If `schema_migrations` doesn't exist, it will be created automatically on first migration

### "Failed to apply migrations"

**Cause**: Could be network issues, SQL errors, or missing dependencies.

**Solution**:
1. Check the browser console for detailed error messages
2. Verify your internet connection
3. Check if GitHub is accessible
4. Review the migration SQL for syntax errors
5. Ensure migrations are applied in the correct order

### "Database exec() function not available"

**Cause**: The `exec()` function hasn't been created in your database yet.

**Solution**:
1. Apply the `20251118103000_create_exec_sql_function.sql` migration manually using Supabase SQL Editor
2. Or use the Supabase CLI: `npx supabase db push`

### Migrations stuck in "Pending" state

**Cause**: The migration was partially applied but not recorded in `schema_migrations`.

**Solution**:
1. Check if the migration's changes are actually in the database
2. If yes, manually insert the version into `schema_migrations`:
   ```sql
   INSERT INTO schema_migrations (version) 
   VALUES ('20251118103000_create_exec_sql_function');
   ```
3. Refresh the Migration Manager

## Alternative Methods

If the Migration Manager doesn't work for you, here are alternatives:

### 1. Supabase CLI (Recommended)
```bash
# Check migration status
npx supabase migration list

# Apply all pending migrations
npx supabase db push

# Or use the npm script
npm run migrate
```

### 2. Manual Application via SQL Editor
1. Open Supabase Dashboard → SQL Editor
2. Copy the content of the migration file
3. Paste into the SQL Editor
4. Click "Run"
5. Manually record in `schema_migrations`:
   ```sql
   INSERT INTO schema_migrations (version) 
   VALUES ('migration_version_here');
   ```

### 3. Supabase Studio
1. Navigate to Database → Migrations in Supabase Dashboard
2. Use the built-in migration tools
3. Apply migrations one by one

## Best Practices

### 1. Always Review Before Applying
- Check what each pending migration does
- Understand the impact on your data
- Ensure you have backups

### 2. Apply in Order
- Migrations should be applied in chronological order
- The system handles this automatically
- Don't skip migrations

### 3. Monitor for Errors
- Watch for error messages
- Check browser console for details
- Review Supabase logs if issues occur

### 4. Keep Your Repository Updated
- Ensure your GitHub repository has the latest migrations
- The system fetches from the `main` branch
- Pull requests should be merged before applying

### 5. Test in Development First
- If possible, test migrations in a development environment
- Apply to production only after verification
- Take database backups before major changes

## Related Documentation

- [Supabase Migrations Guide](./SUPABASE_MIGRATIONS.md) - Complete guide to database migrations
- [RLS Fix Guide](./DOCUMENT_UPLOAD_RLS_FIX.md) - Details on RLS security fixes
- [Security Summary](./SECURITY_SUMMARY.md) - Security considerations and best practices
- [Migration Cheatsheet](./MIGRATION_CHEATSHEET.md) - Quick reference for migration commands

## Support

If you encounter issues with the Migration Manager:

1. Check this guide for troubleshooting steps
2. Review the browser console for error messages
3. Check Supabase logs in the Dashboard
4. Use alternative migration methods (CLI or SQL Editor)
5. Contact the development team for assistance

---

**Last Updated**: 2025-11-18  
**Version**: 1.0  
**Component**: Migration Manager  
**Location**: Dashboard → Overview Tab
