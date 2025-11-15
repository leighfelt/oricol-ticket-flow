# Security hardening applied in fix/security-harden

This PR introduces emergency security hardening to address the highest-risk issues discovered in the security review. It is intentionally conservative and designed to be reviewed and deployed quickly.

## What changed
- Added RLS policies for storage.objects and example policies for profiles and tickets.
- Replaced the public storage-admin-operations function with a secure implementation that requires verified JWT and admin role.
- Added a server-side admin recovery endpoint and removed client-side hardcoded admin checks.
- Added basic zod validation for admin inputs.

## Immediate actions after merging
1. Rotate your Supabase `service_role` key in the Supabase Dashboard and update any trusted server components with the new key.
2. Apply the SQL migrations in `db/policies/*.sql` to your database (via psql or Supabase SQL editor).
3. Deploy the updated Edge Functions and ensure function secrets (SUPABASE_SERVICE_KEY) are set.
4. Test functionality in a staging environment before promoting to production.

## Recommended next steps
- Audit all edge functions and enable JWT verification (verify_jwt = true).
- Remove any other uses of service_role in client code or public endpoints.
- Expand RLS policies to cover all sensitive tables.
- Add CI checks to prevent commits with hardcoded credentials.
