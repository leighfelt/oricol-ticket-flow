import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createServiceRoleClient } from '../_shared/supabase.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

/**
 * Manage user roles edge function
 * 
 * Allows admins to assign/remove roles for users.
 * Uses service role to bypass RLS restrictions while maintaining security.
 * 
 * Security: Only admins can call this function (verified via JWT)
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

    // Check if the requesting user is an admin
    const { data: adminCheck, error: adminCheckError } = await supabaseClient
      .from('user_roles')
      .select('id')
      .eq('user_id', user.id)
      .eq('role', 'admin')
      .single();

    if (adminCheckError || !adminCheck) {
      return new Response(
        JSON.stringify({ error: 'Unauthorized: Admin access required' }),
        {
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
          status: 403,
        }
      );
    }

    // Parse request body
    const body = await req.json();
    const { targetUserId, rolesToSet } = body;

    if (!targetUserId) {
      throw new Error('targetUserId is required');
    }

    if (!Array.isArray(rolesToSet)) {
      throw new Error('rolesToSet must be an array');
    }

    console.log(`Admin ${user.email} managing roles for user ${targetUserId}`);

    // Delete existing roles for the target user
    const { error: deleteError } = await supabaseClient
      .from('user_roles')
      .delete()
      .eq('user_id', targetUserId);

    if (deleteError) {
      console.error('Error deleting existing roles:', deleteError);
      throw new Error(`Failed to delete existing roles: ${deleteError.message}`);
    }

    // Insert new roles
    if (rolesToSet.length > 0) {
      const rolesToInsert = rolesToSet.map(role => ({
        user_id: targetUserId,
        role: role,
      }));

      const { error: insertError } = await supabaseClient
        .from('user_roles')
        .insert(rolesToInsert);

      if (insertError) {
        console.error('Error inserting roles:', insertError);
        throw new Error(`Failed to insert roles: ${insertError.message}`);
      }
    }

    console.log(`✅ Successfully updated roles for user ${targetUserId}`);

    return new Response(
      JSON.stringify({ 
        success: true,
        message: 'User roles updated successfully',
        rolesSet: rolesToSet
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    );
  } catch (error) {
    console.error('Error in manage-user-roles:', error);
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
