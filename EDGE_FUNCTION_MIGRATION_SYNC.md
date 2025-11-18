# Edge Function Migration List Sync Guide

## Problem

The `check-migrations` edge function contains a hardcoded list of migration files. When new migrations are added to the repository, this list becomes outdated, which can cause the function to return incomplete results or errors.

## Current State

The edge function is located at: `supabase/functions/check-migrations/index.ts`

It contains a hardcoded array called `allMigrationFiles` that must be kept in sync with the actual migration files in `supabase/migrations/`.

## When to Update

**You MUST update the edge function whenever:**
- A new migration file is added to `supabase/migrations/`
- A migration file is renamed or deleted
- Any changes are made to the migration files

## How to Update

### Quick Method

1. List all migration files:
   ```bash
   ls -1 supabase/migrations/*.sql | xargs -n1 basename
   ```

2. Copy the output and format it as a TypeScript array with each filename in double quotes

3. Update the `allMigrationFiles` array in `supabase/functions/check-migrations/index.ts`

### Verification Script

Run this Node.js script to verify the list is up to date:

```javascript
const fs = require('fs');
const path = require('path');

const actualFiles = fs.readdirSync('supabase/migrations')
  .filter(f => f.endsWith('.sql'))
  .sort();

const functionFile = fs.readFileSync('supabase/functions/check-migrations/index.ts', 'utf8');
const matches = functionFile.match(/const allMigrationFiles = \[([\s\S]*?)\];/);

const listedFiles = matches[1]
  .split('\n')
  .map(line => line.trim())
  .filter(line => line.startsWith('"'))
  .map(line => line.replace(/^"|",$|",$/g, ''))
  .sort();

const missing = actualFiles.filter(f => !listedFiles.includes(f));
const extra = listedFiles.filter(f => !actualFiles.includes(f));

if (missing.length === 0 && extra.length === 0) {
  console.log('✅ Migration list is up to date');
} else {
  if (missing.length > 0) {
    console.error('❌ Missing:', missing);
  }
  if (extra.length > 0) {
    console.error('❌ Extra:', extra);
  }
  process.exit(1);
}
```

## Future Improvements

To avoid this manual synchronization in the future, consider:

1. **Use GitHub API**: Fetch the migration list dynamically from the GitHub repository
2. **Use Deno.readDir**: Read the migrations directory at runtime (if accessible)
3. **Automated CI Check**: Add a CI job that validates the migration list is in sync
4. **Pre-commit Hook**: Add a git pre-commit hook that checks for sync issues

## Related Files

- Edge Function: `supabase/functions/check-migrations/index.ts`
- Migrations Directory: `supabase/migrations/`
- Shared Client: `supabase/functions/_shared/supabase.ts`

## Last Updated

- **Date**: 2025-11-18
- **Migration Count**: 60 files
- **Last Migration**: `verify_admin_roles.sql`
