/**
 * Information function for storage RLS policies
 * 
 * This function provides information about storage policies for documents and diagrams buckets.
 * Policies are created via database migrations, not through this edge function.
 * 
 * Returns success with details about which migrations manage the policies.
 */

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    console.log('Verifying storage policies setup...');
    
    // This function used to attempt to create storage policies programmatically,
    // but that approach is problematic because:
    // 1. It requires an RPC function that doesn't exist in standard Supabase
    // 2. Storage policies should be managed via database migrations for proper version control
    // 3. The policies already exist in migrations
    
    // The storage policies are created and managed via these migrations:
    // - 20251113142600_create_documents_table_and_bucket.sql
    // - 20251113151700_fix_documents_storage_policies.sql  
    // - 20251113111200_create_diagrams_storage_bucket.sql
    
    // These migrations create the following policies:
    const policiesInfo = [
      {
        name: 'Authenticated users can upload documents to storage',
        bucket: 'documents',
        operation: 'INSERT',
        role: 'authenticated'
      },
      {
        name: 'Public users can view documents in storage',
        bucket: 'documents',
        operation: 'SELECT',
        role: 'public'
      },
      {
        name: 'Authenticated users can update documents in storage',
        bucket: 'documents',
        operation: 'UPDATE',
        role: 'authenticated'
      },
      {
        name: 'Authenticated users can delete documents from storage',
        bucket: 'documents',
        operation: 'DELETE',
        role: 'authenticated'
      },
      {
        name: 'Authenticated users can upload diagrams',
        bucket: 'diagrams',
        operation: 'INSERT',
        role: 'authenticated'
      },
      {
        name: 'Public users can view diagrams',
        bucket: 'diagrams',
        operation: 'SELECT',
        role: 'public'
      },
      {
        name: 'Authenticated users can update diagrams',
        bucket: 'diagrams',
        operation: 'UPDATE',
        role: 'authenticated'
      },
      {
        name: 'Authenticated users can delete diagrams',
        bucket: 'diagrams',
        operation: 'DELETE',
        role: 'authenticated'
      }
    ];

    console.log('Storage policies are managed via database migrations');

    return new Response(
      JSON.stringify({
        success: true,
        message: 'Storage policies are managed via database migrations',
        note: 'Policies are created automatically when migrations are applied',
        migrations: [
          '20251113142600_create_documents_table_and_bucket.sql',
          '20251113151700_fix_documents_storage_policies.sql',
          '20251113111200_create_diagrams_storage_bucket.sql'
        ],
        policies: policiesInfo,
        instructions: {
          title: 'If you are experiencing storage permission errors:',
          steps: [
            '1. Ensure all migrations have been applied to your database',
            '2. Run: supabase db push (for local development)',
            '3. For production: migrations are applied automatically on deployment',
            '4. Verify policies exist in Supabase Dashboard: Storage → Policies',
            '5. Check that RLS is disabled on storage.buckets table (should be disabled per migration 20251114072100_disable_storage_buckets_rls.sql)'
          ]
        }
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );

  } catch (error) {
    console.error('Error setting up storage policies:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    
    return new Response(
      JSON.stringify({
        success: false,
        error: errorMessage,
        note: 'Storage policies must be created via Supabase Dashboard under Storage → Settings → Policies'
      }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    );
  }
});