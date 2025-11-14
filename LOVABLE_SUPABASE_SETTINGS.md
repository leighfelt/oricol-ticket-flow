# How to Update Supabase Settings on Lovable

## Your Current Supabase Configuration

Your project is connected to:
- **Project ID**: `kwmeqvrmtivmljujwocp`
- **Supabase URL**: `https://kwmeqvrmtivmljujwocp.supabase.co`
- **Lovable Project URL**: https://lovable.dev/projects/c75c70a7-c13d-4879-a8af-bbb8cc076141

## Where to Find Supabase Settings in Lovable

### Option 1: Through Lovable Dashboard (Recommended)

1. **Go to your Lovable project**:
   - Open: https://lovable.dev/projects/c75c70a7-c13d-4879-a8af-bbb8cc076141

2. **Access Integrations**:
   - Click on the **"Integrations"** tab in the left sidebar
   - OR click on **"Settings"** → **"Integrations"**

3. **Find Supabase Integration**:
   - Look for the **Supabase** integration card
   - Click **"Configure"** or **"Edit"** button

4. **Update Environment Variables**:
   The following variables can be updated:
   - `VITE_SUPABASE_URL` - Your Supabase project URL
   - `VITE_SUPABASE_PUBLISHABLE_KEY` - Your Supabase anon/public key
   - `VITE_SUPABASE_PROJECT_ID` - Your Supabase project ID

### Option 2: Through Environment Variables

1. **In Lovable Project Dashboard**:
   - Go to: https://lovable.dev/projects/c75c70a7-c13d-4879-a8af-bbb8cc076141
   
2. **Navigate to Environment Settings**:
   - Click on **"Settings"** in the left sidebar
   - Select **"Environment Variables"** or **"Secrets"**

3. **Add/Update Variables**:
   - Click **"Add Variable"** or edit existing ones
   - Enter your Supabase credentials:
     ```
     VITE_SUPABASE_URL=https://kwmeqvrmtivmljujwocp.supabase.co
     VITE_SUPABASE_PUBLISHABLE_KEY=your_anon_key_here
     VITE_SUPABASE_PROJECT_ID=kwmeqvrmtivmljujwocp
     ```

### Option 3: Edit .env File Directly (Alternative)

If you need to update the `.env` file:

1. **In Lovable Code Editor**:
   - Open the `.env` file in the root directory
   - Update the values:
     ```env
     VITE_SUPABASE_PROJECT_ID="kwmeqvrmtivmljujwocp"
     VITE_SUPABASE_PUBLISHABLE_KEY="your_key_here"
     VITE_SUPABASE_URL="https://kwmeqvrmtivmljujwocp.supabase.co"
     ```
   - Save the file (changes sync automatically)

2. **Or Edit on GitHub**:
   - Edit the `.env` file in this repository
   - Commit your changes
   - Lovable will sync automatically

## Getting Your Supabase Credentials

If you need to find or reset your Supabase credentials:

1. **Go to Supabase Dashboard**:
   - Visit: https://supabase.com/dashboard
   - Log in to your account

2. **Select Your Project**:
   - Click on your project: `kwmeqvrmtivmljujwocp`

3. **Find Project Settings**:
   - Click on the **Settings** icon (gear icon) in the sidebar
   - Select **API** from the settings menu

4. **Copy Your Credentials**:
   - **Project URL**: Copy from the "Configuration" section
   - **Project API key** (anon key): Copy the `anon` `public` key
   - **Project Ref**: This is your project ID

## Important Notes About Storage Policies

⚠️ **About the Storage Policies Setup Function**:

The edge function `setup-storage-policies` has been updated to no longer attempt to create policies programmatically. Instead:

- ✅ Storage policies are **automatically created via database migrations**
- ✅ Migrations are applied when you deploy or push to Supabase
- ✅ The function now returns success with information about the policies

**If you see storage permission errors**:

1. Ensure all migrations have been applied:
   ```bash
   supabase db push
   ```

2. Check these key migrations exist in your database:
   - `20251113142600_create_documents_table_and_bucket.sql`
   - `20251113151700_fix_documents_storage_policies.sql`
   - `20251113111200_create_diagrams_storage_bucket.sql`
   - `20251114072100_disable_storage_buckets_rls.sql`

3. Verify in Supabase Dashboard:
   - Go to **Storage** → **Policies**
   - You should see policies for:
     - `documents` bucket (upload, select, update, delete)
     - `diagrams` bucket (upload, select, update, delete)

## Troubleshooting

### Changes Not Appearing in Lovable?

1. **Check Sync Status**:
   - Lovable should show sync status in the UI
   - Look for a sync indicator or notification

2. **Redeploy the App**:
   - In Lovable, click **"Deploy"** or **"Restart"**
   - This forces a fresh build with new environment variables

3. **Clear Cache**:
   - Hard refresh your browser (Ctrl+Shift+R or Cmd+Shift+R)
   - Clear browser cache and reload

### Still Having Issues?

- Check the Lovable documentation: https://docs.lovable.dev
- Check Supabase documentation: https://supabase.com/docs
- Verify your Supabase project is active (not paused)
- Check that your API keys are correct and not expired

## Next Steps After Updating Settings

After updating Supabase settings:

1. ✅ App will automatically redeploy with new settings
2. ✅ Test the connection by trying to log in
3. ✅ Verify storage uploads work correctly
4. ✅ Check that database queries are working

## Contact & Support

- **Lovable Support**: Check the Lovable help center
- **Supabase Support**: https://supabase.com/support
- **Project Repository**: This GitHub repository
