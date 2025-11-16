import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface ImportRequest {
  staff_user_ids: string[];
}

interface ImportResult {
  success: boolean;
  email?: string;
  username?: string;
  password?: string;
  error?: string;
  message?: string;
}

// Generate a random password
function generateRandomPassword(length: number = 16): string {
  const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*";
  let password = "";
  const crypto = globalThis.crypto;
  const array = new Uint8Array(length);
  crypto.getRandomValues(array);
  
  for (let i = 0; i < length; i++) {
    password += chars[array[i] % chars.length];
  }
  
  return password;
}

const handler = async (req: Request): Promise<Response> => {
  // Handle CORS preflight requests
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    // Create Supabase client with service role key for admin operations
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
      },
    });

    // Get the request body
    const { staff_user_ids }: ImportRequest = await req.json();

    if (!staff_user_ids || !Array.isArray(staff_user_ids) || staff_user_ids.length === 0) {
      return new Response(
        JSON.stringify({ error: "staff_user_ids array is required" }),
        { 
          status: 400, 
          headers: { ...corsHeaders, "Content-Type": "application/json" } 
        }
      );
    }

    const results: ImportResult[] = [];
    let successCount = 0;
    let errorCount = 0;

    // Process each staff user
    for (const staffUserId of staff_user_ids) {
      try {
        // Get staff user details
        const { data: staffUser, error: fetchError } = await supabaseAdmin
          .from("vpn_rdp_credentials")
          .select("id, username, email, service_type, notes")
          .eq("id", staffUserId)
          .single();

        if (fetchError || !staffUser) {
          results.push({
            success: false,
            error: "Staff user not found",
          });
          errorCount++;
          continue;
        }

        if (!staffUser.email) {
          results.push({
            success: false,
            username: staffUser.username,
            error: "Staff user has no email address",
          });
          errorCount++;
          continue;
        }

        // Check if user already exists
        const { data: existingUser } = await supabaseAdmin.auth.admin.listUsers();
        const userExists = existingUser.users.some(
          (u) => u.email?.toLowerCase() === staffUser.email.toLowerCase()
        );

        if (userExists) {
          results.push({
            success: false,
            email: staffUser.email,
            username: staffUser.username,
            error: "User already exists with this email",
          });
          errorCount++;
          continue;
        }

        // Generate random password
        const password = generateRandomPassword(16);

        // Create the user using Supabase Admin API
        const { data: newUser, error: createError } = await supabaseAdmin.auth.admin.createUser({
          email: staffUser.email,
          password: password,
          email_confirm: true, // Auto-confirm email
          user_metadata: {
            full_name: staffUser.username,
            username: staffUser.username,
            imported_from_staff: true,
            original_staff_id: staffUser.id,
          },
        });

        if (createError || !newUser) {
          results.push({
            success: false,
            email: staffUser.email,
            username: staffUser.username,
            error: createError?.message || "Failed to create user",
          });
          errorCount++;
          continue;
        }

        // Update the profile with additional information
        const { error: profileError } = await supabaseAdmin
          .from("profiles")
          .update({
            full_name: staffUser.username,
            username: staffUser.username,
          })
          .eq("id", newUser.user.id);

        if (profileError) {
          console.error("Failed to update profile:", profileError);
          // Don't fail the whole import if profile update fails
        }

        results.push({
          success: true,
          email: staffUser.email,
          username: staffUser.username,
          password: password,
          message: "User created successfully",
        });
        successCount++;
      } catch (error) {
        console.error("Error processing staff user:", error);
        results.push({
          success: false,
          error: error instanceof Error ? error.message : "Unknown error",
        });
        errorCount++;
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        total: staff_user_ids.length,
        success_count: successCount,
        error_count: errorCount,
        results: results,
      }),
      { 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      }
    );
  } catch (error) {
    console.error("Error in import-staff-users function:", error);
    return new Response(
      JSON.stringify({ 
        error: error instanceof Error ? error.message : "Internal server error" 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, "Content-Type": "application/json" } 
      }
    );
  }
};

serve(handler);
