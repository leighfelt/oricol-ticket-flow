import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createServiceRoleClient } from '../_shared/supabase.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

/**
 * Auto-assign admin role edge function
 * 
 * This function checks if a user's email matches any admin pattern
 * and automatically assigns the admin role if it does.
 * 
 * Security: Uses service role to bypass RLS when assigning roles
 * Only callable by authenticated users for their own account
 */
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Get the user from the request (authenticated user)
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      throw new Error('Missing authorization header');
    }

    const supabaseClient = createServiceRoleClient();

    // Extract the JWT token
    const token = authHeader.replace('Bearer ', '');
    
    // Verify the user's token and get their info
    const { data: { user }, error: userError } = await supabaseClient.auth.getUser(token);
    
    if (userError || !user) {
      throw new Error('Invalid or expired token');
    }

    console.log(`Checking admin status for user: ${user.email}`);

    // Check if this email matches any admin pattern
    const { data: isAdmin, error: checkError } = await supabaseClient
      .rpc('is_admin_email', { email_to_check: user.email || '' });

    if (checkError) {
      console.error('Error checking admin email:', checkError);
      throw checkError;
    }

    console.log(`User ${user.email} admin check result: ${isAdmin}`);

    if (!isAdmin) {
      return new Response(
        JSON.stringify({ 
          isAdmin: false,
          message: 'User email does not match any admin pattern'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      );
    }

    // Check if user already has admin role
    const { data: existingAdminRole } = await supabaseClient
      .from('user_roles')
      .select('id')
      .eq('user_id', user.id)
      .eq('role', 'admin')
      .single();

    if (existingAdminRole) {
      console.log(`User ${user.email} already has admin role`);
      return new Response(
        JSON.stringify({ 
          isAdmin: true,
          alreadyAssigned: true,
          message: 'User already has admin role'
        }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 200,
        }
      );
    }

    // Assign admin role
    console.log(`Assigning admin role to user: ${user.email}`);
    const { error: adminRoleError } = await supabaseClient
      .from('user_roles')
      .insert([{ user_id: user.id, role: 'admin' }]);

    if (adminRoleError) {
      // Check if it's a unique constraint violation (role already exists)
      if (adminRoleError.code === '23505') {
        console.log(`Admin role already exists for user: ${user.email}`);
        return new Response(
          JSON.stringify({ 
            isAdmin: true,
            alreadyAssigned: true,
            message: 'Admin role already exists'
          }),
          {
            headers: { ...corsHeaders, 'Content-Type': 'application/json' },
            status: 200,
          }
        );
      }
      throw adminRoleError;
    }

    // Check if user has the base 'user' role, if not add it
    const { data: existingUserRole } = await supabaseClient
      .from('user_roles')
      .select('id')
      .eq('user_id', user.id)
      .eq('role', 'user')
      .single();

    if (!existingUserRole) {
      console.log(`Assigning user role to: ${user.email}`);
      await supabaseClient
        .from('user_roles')
        .insert([{ user_id: user.id, role: 'user' }]);
    }

    console.log(`✅ Successfully assigned admin role to: ${user.email}`);

    return new Response(
      JSON.stringify({ 
        isAdmin: true,
        alreadyAssigned: false,
        message: 'Admin role assigned successfully'
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('Error in auto-assign-admin-role:', error);
    const errorMessage = error instanceof Error ? error.message : 'Unknown error';
    
    return new Response(
      JSON.stringify({ 
        error: errorMessage,
        timestamp: new Date().toISOString()
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 500,
      }
    );
  }
});
