#!/usr/bin/env node

/**
 * Migration Status Checker
 * 
 * This script checks the status of all migrations and provides a summary.
 * 
 * Usage:
 *   npm run migrate:status
 */

import { createClient } from '@supabase/supabase-js';
import { readdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Colors
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  cyan: '\x1b[36m',
  gray: '\x1b[90m',
};

// Initialize Supabase client
const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_PUBLISHABLE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error(`${colors.red}❌ Missing Supabase credentials${colors.reset}`);
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkMigrationStatus() {
  console.log(`${colors.cyan}═══════════════════════════════════════════════${colors.reset}`);
  console.log(`${colors.cyan}   Migration Status Report${colors.reset}`);
  console.log(`${colors.cyan}═══════════════════════════════════════════════${colors.reset}\n`);
  
  // Get all migration files
  const migrationsDir = join(__dirname, '../supabase/migrations');
  const allMigrations = readdirSync(migrationsDir)
    .filter(file => file.endsWith('.sql'))
    .sort();
  
  console.log(`${colors.gray}📁 Total migrations found:${colors.reset} ${allMigrations.length}\n`);
  
  // Get applied migrations
  const { data: appliedData } = await supabase
    .from('schema_migrations')
    .select('version, applied_at')
    .order('applied_at', { ascending: true });
  
  const appliedMigrations = new Set(appliedData?.map(row => row.version) || []);
  
  console.log(`${colors.green}✅ Applied migrations:${colors.reset} ${appliedMigrations.size}`);
  console.log(`${colors.yellow}⏳ Pending migrations:${colors.reset} ${allMigrations.length - appliedMigrations.size}\n`);
  
  console.log(`${colors.cyan}Migration Status:${colors.reset}\n`);
  
  allMigrations.forEach((migration, index) => {
    const isApplied = appliedMigrations.has(migration);
    const status = isApplied 
      ? `${colors.green}✓ Applied${colors.reset}` 
      : `${colors.yellow}⏳ Pending${colors.reset}`;
    
    console.log(`${colors.gray}${String(index + 1).padStart(3)}.${colors.reset} ${status} ${migration}`);
  });
  
  console.log(`\n${colors.cyan}═══════════════════════════════════════════════${colors.reset}\n`);
  
  if (allMigrations.length === appliedMigrations.size) {
    console.log(`${colors.green}✨ All migrations are up to date!${colors.reset}\n`);
  } else {
    console.log(`${colors.yellow}⚠️  You have ${allMigrations.length - appliedMigrations.size} pending migration(s)${colors.reset}`);
    console.log(`${colors.gray}Run ${colors.cyan}npm run migrate${colors.gray} to see details${colors.reset}\n`);
  }
}

checkMigrationStatus().catch(error => {
  console.error(`${colors.red}❌ Error:${colors.reset}`, error);
  process.exit(1);
});
