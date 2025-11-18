import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    // Get already applied migrations
    const { data: appliedMigrations, error: migrationsError } = await supabaseClient
      .from('schema_migrations')
      .select('version');

    if (migrationsError && migrationsError.code !== 'PGRST116') {
      throw migrationsError;
    }

    const appliedVersions = new Set(
      (appliedMigrations || []).map((m: any) => m.version)
    );

    // Map of migration files to their SQL content
    // In production, you'd fetch these from GitHub or read from filesystem
    const migrationFiles: Record<string, string> = {
      // Add migration content here or fetch from GitHub
      // For now, we'll just track which ones to apply
    };

    let appliedCount = 0;
    const errors = [];

    // Get pending migrations from the hardcoded list
    const allMigrations = Object.keys(migrationFiles);
    const pendingMigrations = allMigrations.filter(
      (filename) => !appliedVersions.has(filename.replace('.sql', ''))
    );

    console.log(`Found ${pendingMigrations.length} pending migrations`);

    // Apply each pending migration
    for (const filename of pendingMigrations) {
      const sql = migrationFiles[filename];
      const version = filename.replace('.sql', '');

      try {
        // Execute the migration SQL
        const { error: sqlError } = await supabaseClient.rpc('exec_sql', {
          sql_query: sql,
        });

        if (sqlError) throw sqlError;

        // Record that this migration was applied
        const { error: recordError } = await supabaseClient
          .from('schema_migrations')
          .insert({ version });

        if (recordError) throw recordError;

        appliedCount++;
        console.log(`✓ Applied migration: ${filename}`);
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Unknown error';
        console.error(`✗ Failed to apply migration ${filename}:`, error);
        errors.push({ filename, error: errorMessage });
      }
    }

    if (errors.length > 0) {
      return new Response(
        JSON.stringify({
          appliedCount,
          errors,
          message: `Applied ${appliedCount} migrations with ${errors.length} errors`,
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 207, // Multi-status
        }
      );
    }

    return new Response(
      JSON.stringify({
        appliedCount,
        message: appliedCount === 0
          ? 'No pending migrations to apply'
          : `Successfully applied ${appliedCount} migration(s)`,
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('Error applying migrations:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    return new Response(
      JSON.stringify({ error: errorMessage }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});
