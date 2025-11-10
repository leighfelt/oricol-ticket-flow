import { serve } from "https://deno.land/std@0.190.0/http/server.ts";
import { Resend } from "https://esm.sh/resend@4.0.0";

const resend = new Resend(Deno.env.get("RESEND_API_KEY"));

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface TicketEmailRequest {
  ticketId: string;
  title: string;
  description: string;
  faultType: string;
  branch: string;
  userEmail: string;
  errorCode?: string;
  priority: string;
}

const handler = async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  try {
    const { ticketId, title, description, faultType, branch, userEmail, errorCode, priority }: TicketEmailRequest = await req.json();

    console.log("Processing ticket email routing:", { ticketId, faultType, branch });

    // Route to Qwerti for RDP issues
    if (faultType === "RDP") {
      const emailResponse = await resend.emails.send({
        from: "Oricol Helpdesk <onboarding@resend.dev>",
        to: ["support@qwerti.co.za"],
        subject: `[RDP Ticket] ${title} - ${branch}`,
        html: `
          <h2>New RDP Support Ticket</h2>
          <p><strong>Ticket ID:</strong> ${ticketId}</p>
          <p><strong>Branch:</strong> ${branch}</p>
          <p><strong>User Email:</strong> ${userEmail}</p>
          <p><strong>Priority:</strong> ${priority.toUpperCase()}</p>
          <p><strong>Fault Type:</strong> ${faultType}</p>
          ${errorCode ? `<p><strong>Error Code:</strong> ${errorCode}</p>` : ''}
          <h3>Description:</h3>
          <p>${description || 'No description provided'}</p>
          <hr>
          <p><em>This ticket was automatically routed from Oricol Helpdesk</em></p>
        `,
      });

      console.log("RDP Email sent to Qwerti:", emailResponse);
    }

    // Send confirmation to user
    const confirmationResponse = await resend.emails.send({
      from: "Oricol Helpdesk <onboarding@resend.dev>",
      to: [userEmail],
      subject: `Ticket Created: ${title}`,
      html: `
        <h2>Your Support Ticket Has Been Created</h2>
        <p>Thank you for submitting your support request.</p>
        <p><strong>Ticket ID:</strong> ${ticketId}</p>
        <p><strong>Branch:</strong> ${branch}</p>
        <p><strong>Fault Type:</strong> ${faultType}</p>
        <p><strong>Priority:</strong> ${priority.toUpperCase()}</p>
        ${faultType === "RDP" ? '<p><em>This ticket has been routed to Qwerti for RDP support.</em></p>' : ''}
        <h3>Description:</h3>
        <p>${description || 'No description provided'}</p>
        <hr>
        <p>We will respond to your ticket as soon as possible.</p>
        <p><em>Oricol Helpdesk - Centralised IT Management</em></p>
      `,
    });

    console.log("Confirmation email sent to user:", confirmationResponse);

    return new Response(
      JSON.stringify({ success: true, message: "Emails sent successfully" }),
      {
        status: 200,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  } catch (error: any) {
    console.error("Error in route-ticket-email function:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { "Content-Type": "application/json", ...corsHeaders },
      }
    );
  }
};

serve(handler);
