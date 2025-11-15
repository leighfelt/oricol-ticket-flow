# Supabase Environment Variables Setup

This document explains the proper environment variable configuration for the Lovable auto-configured Supabase integration.

## Overview

The application uses environment variables to connect to Supabase, ensuring it works seamlessly with Lovable's auto-configured integration without hardcoded project-specific values.

## Required Environment Variables

### For Client-Side (Vite)

These variables are used by the frontend application:

```env
VITE_SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key-here
VITE_SUPABASE_PROJECT_ID=YOUR-PROJECT-ID
```

### For Edge Functions (Supabase Functions)

These variables are automatically provided by Supabase to edge functions:

```env
SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here
```

### Optional: Web Application URL

For email confirmation links and other web URLs:

```env
WEB_APP_URL=https://YOUR-PROJECT-ID.lovable.app
```

If not set, the system will automatically construct this from `SUPABASE_URL` by replacing `.supabase.co` with `.lovable.app`.

## Lovable Auto-Configuration

When using Lovable's auto-configured Supabase integration:

1. **Lovable automatically sets** the environment variables in the platform
2. **The repository `.env` file** is for local development only
3. **Production values** come from Lovable's environment configuration

### How to Verify Lovable Configuration

1. Go to your Lovable project: https://lovable.dev/projects/c75c70a7-c13d-4879-a8af-bbb8cc076141
2. Navigate to **Settings → Environment Variables**
3. Verify these variables are set:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`
   - `VITE_SUPABASE_PROJECT_ID`
4. Optionally add: `WEB_APP_URL` (if you want a custom domain)

## Why No Hardcoded Values?

Previously, the code had hardcoded project IDs like:

```typescript
// ❌ BAD - Hardcoded project ID
const url = SUPABASE_URL.replace('https://kwmeqvrmtivmljujwocp.supabase.co', 'https://kwmeqvrmtivmljujwocp.lovable.app');
```

This caused issues:

- **RLS Policy Conflicts**: Functions might connect to wrong instance
- **Environment Mismatch**: Can't switch between dev/staging/production
- **Integration Conflicts**: Breaks Lovable's auto-configuration
- **Deployment Issues**: Doesn't work with custom domains

Now the code uses dynamic values:

```typescript
// ✅ GOOD - Uses environment variables
const webAppUrl = Deno.env.get("WEB_APP_URL") || Deno.env.get("SUPABASE_URL")?.replace('.supabase.co', '.lovable.app');
```

## Current Project Configuration

Your current Lovable auto-configured setup:

- **Project ID**: `kwmeqvrmtivmljujwocp`
- **Supabase URL**: `https://kwmeqvrmtivmljujwocp.supabase.co`
- **Lovable App URL**: `https://kwmeqvrmtivmljujwocp.lovable.app`

These values should be set in environment variables, not hardcoded in the code.

## Setting Up Edge Functions

Edge functions automatically receive Supabase environment variables. No additional configuration needed.

If you need to set the web app URL:

1. In Supabase Dashboard: https://supabase.com/dashboard/project/kwmeqvrmtivmljujwocp
2. Go to **Edge Functions → Settings**
3. Add environment variable:
   - Key: `WEB_APP_URL`
   - Value: `https://kwmeqvrmtivmljujwocp.lovable.app` (or your custom domain)

## Troubleshooting

### RLS Policy Errors

If you get "new row violates row-level security policy" errors:

1. Verify environment variables are set correctly in Lovable
2. Check that no hardcoded URLs remain in the code
3. Ensure client and server use the same Supabase instance
4. See [QUICKFIX_START_HERE.md](./QUICKFIX_START_HERE.md) for RLS-specific fixes

### Connection Issues

If the app can't connect to Supabase:

1. Check environment variables in Lovable Settings
2. Verify `.env` file for local development
3. Ensure keys match your Supabase project
4. See [VERIFY_SUPABASE_CONNECTION.md](./VERIFY_SUPABASE_CONNECTION.md)

### Multiple Instances/Conflicts

If you suspect multiple Supabase configurations:

1. Check for hardcoded URLs in the code (should be none now)
2. Verify only one set of environment variables in Lovable
3. Ensure `.env` file matches Lovable configuration
4. Clear browser cache and reload

## Migration from Hardcoded to Environment Variables

The following changes were made to support Lovable auto-configuration:

### Removed Hardcoded Values

- ✅ `supabase/functions/send-staff-onboarding-email/index.ts` - Removed hardcoded project ID
- ✅ All code now uses `WEB_APP_URL` or dynamic construction

### Benefits

- ✅ Works with Lovable auto-configuration
- ✅ Supports custom domains
- ✅ No RLS policy conflicts
- ✅ Environment-agnostic code
- ✅ Easier testing and deployment

## See Also

- [FIND_YOUR_SUPABASE_CONNECTION.md](./FIND_YOUR_SUPABASE_CONNECTION.md) - Finding your Supabase connection
- [VERIFY_SUPABASE_CONNECTION.md](./VERIFY_SUPABASE_CONNECTION.md) - Verifying your setup
- [LOCAL_SETUP.md](./LOCAL_SETUP.md) - Local development setup
