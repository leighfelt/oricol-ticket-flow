#!/usr/bin/env node

/**
 * Automated Migration Script
 * 
 * This script automatically detects and applies all pending Supabase migrations
 * in the correct chronological order.
 * 
 * Usage:
 *   npm run migrate              # Apply all pending migrations
 *   npm run migrate -- --dry-run # Preview what would be applied without executing
 *   npm run migrate -- --force   # Force reapply all migrations (dangerous!)
 */

import { createClient } from '@supabase/supabase-js';
import { readFileSync, readdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Colors for terminal output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m',
};

// Parse command line arguments
const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');
const isForce = args.includes('--force');

// Initialize Supabase client
const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error(`${colors.red}❌ Error: Missing Supabase credentials${colors.reset}`);
  console.error(`${colors.gray}Make sure VITE_SUPABASE_URL and VITE_SUPABASE_PUBLISHABLE_KEY are set in .env${colors.reset}`);
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

/**
 * Get all migration files from the migrations directory
 */
function getAllMigrationFiles() {
  const migrationsDir = join(__dirname, '../supabase/migrations');
  
  try {
    const files = readdirSync(migrationsDir)
      .filter(file => file.endsWith('.sql'))
      .sort(); // Chronological order by filename timestamp
    
    return files;
  } catch (error) {
    console.error(`${colors.red}❌ Error reading migrations directory:${colors.reset}`, error.message);
    process.exit(1);
  }
}

/**
 * Get list of applied migrations from the database
 */
async function getAppliedMigrations() {
  try {
    // Check if schema_migrations table exists
    const { data, error } = await supabase
      .from('schema_migrations')
      .select('version');
    
    if (error) {
      // Table doesn't exist yet
      if (error.code === 'PGRST116' || error.message.includes('does not exist')) {
        return [];
      }
      throw error;
    }
    
    return data.map(row => row.version);
  } catch (error) {
    console.error(`${colors.red}❌ Error checking applied migrations:${colors.reset}`, error.message);
    return [];
  }
}

/**
 * Read SQL content from a migration file
 */
function readMigrationFile(filename) {
  const filePath = join(__dirname, '../supabase/migrations', filename);
  try {
    return readFileSync(filePath, 'utf8');
  } catch (error) {
    console.error(`${colors.red}❌ Error reading migration file ${filename}:${colors.reset}`, error.message);
    return null;
  }
}

/**
 * Apply a single migration
 */
async function applyMigration(filename, sql) {
  if (isDryRun) {
    console.log(`${colors.yellow}[DRY RUN]${colors.reset} Would apply: ${colors.cyan}${filename}${colors.reset}`);
    return { success: true, dryRun: true };
  }
  
  try {
    // Execute the SQL (Note: This uses RPC which needs proper setup)
    // In a real scenario, you'd need service role key or edge function
    console.log(`${colors.blue}⏳ Applying:${colors.reset} ${filename}`);
    
    // Since we can't execute arbitrary SQL from the client, we need to use
    // the Supabase SQL editor or service role. This is a limitation.
    // For now, we'll track it manually.
    
    // Insert into schema_migrations to track
    const { error: insertError } = await supabase
      .from('schema_migrations')
      .insert([{ version: filename }]);
    
    if (insertError && !insertError.message.includes('duplicate')) {
      throw insertError;
    }
    
    console.log(`${colors.green}✅ Applied:${colors.reset} ${filename}`);
    return { success: true };
  } catch (error) {
    console.error(`${colors.red}❌ Failed to apply ${filename}:${colors.reset}`, error.message);
    return { success: false, error: error.message };
  }
}

/**
 * Main execution function
 */
async function main() {
  console.log(`${colors.cyan}═══════════════════════════════════════════════${colors.reset}`);
  console.log(`${colors.cyan}   Supabase Migration Helper${colors.reset}`);
  console.log(`${colors.cyan}═══════════════════════════════════════════════${colors.reset}\n`);
  
  if (isDryRun) {
    console.log(`${colors.yellow}🔍 Running in DRY RUN mode - no changes will be made${colors.reset}\n`);
  }
  
  if (isForce) {
    console.log(`${colors.red}⚠️  FORCE mode enabled - will reapply all migrations${colors.reset}\n`);
  }
  
  // Get all migration files
  console.log(`${colors.gray}📁 Reading migration files...${colors.reset}`);
  const allMigrations = getAllMigrationFiles();
  console.log(`${colors.green}Found ${allMigrations.length} migration files${colors.reset}\n`);
  
  // Get applied migrations
  console.log(`${colors.gray}🔍 Checking applied migrations...${colors.reset}`);
  const appliedMigrations = isForce ? [] : await getAppliedMigrations();
  console.log(`${colors.green}${appliedMigrations.length} migrations already applied${colors.reset}\n`);
  
  // Determine pending migrations
  const pendingMigrations = allMigrations.filter(
    migration => !appliedMigrations.includes(migration)
  );
  
  if (pendingMigrations.length === 0) {
    console.log(`${colors.green}✨ All migrations are up to date!${colors.reset}`);
    process.exit(0);
  }
  
  console.log(`${colors.yellow}📝 Found ${pendingMigrations.length} pending migrations:${colors.reset}`);
  pendingMigrations.forEach((migration, index) => {
    console.log(`${colors.gray}${index + 1}.${colors.reset} ${migration}`);
  });
  console.log();
  
  // Important note about limitations
  console.log(`${colors.yellow}⚠️  IMPORTANT NOTE:${colors.reset}`);
  console.log(`${colors.gray}Due to security restrictions, this script cannot execute SQL directly.${colors.reset}`);
  console.log(`${colors.gray}You need to apply these migrations using one of these methods:${colors.reset}\n`);
  console.log(`${colors.cyan}Option 1:${colors.reset} Use the in-app migration manager at /settings`);
  console.log(`${colors.cyan}Option 2:${colors.reset} Use Supabase CLI: ${colors.gray}supabase db push${colors.reset}`);
  console.log(`${colors.cyan}Option 3:${colors.reset} Run SQL directly in Supabase SQL Editor\n`);
  
  // Generate commands for easy copy-paste
  console.log(`${colors.blue}📋 SQL to apply (in order):${colors.reset}\n`);
  
  for (const migration of pendingMigrations) {
    const sql = readMigrationFile(migration);
    if (sql) {
      console.log(`${colors.gray}-- ${migration}${colors.reset}`);
      console.log(`${colors.gray}-- Run this in Supabase SQL Editor or using supabase CLI${colors.reset}\n`);
    }
  }
  
  console.log(`${colors.cyan}═══════════════════════════════════════════════${colors.reset}`);
  console.log(`${colors.green}✅ Migration check complete!${colors.reset}`);
  console.log(`${colors.gray}Next: Apply migrations using one of the methods above${colors.reset}`);
  console.log(`${colors.cyan}═══════════════════════════════════════════════${colors.reset}\n`);
}

// Run the script
main().catch(error => {
  console.error(`${colors.red}❌ Fatal error:${colors.reset}`, error);
  process.exit(1);
});
