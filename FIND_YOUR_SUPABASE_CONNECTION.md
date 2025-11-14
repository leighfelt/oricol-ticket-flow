# How to Find Your Supabase Connection in Lovable

## The Problem
You're using a **Lovable app** that's connected to **Supabase**, but you're unsure which Supabase project it's actually using. You may have:
- Added a Supabase integration manually in Lovable
- Multiple Supabase projects in your account
- Uncertainty about whether Lovable created its own Supabase instance

## Quick Answer: Your Current Supabase Configuration

Based on your repository configuration, your app is currently configured to use:

```
Project ID:   kwmeqvrmtivmljujwocp
Project URL:  https://kwmeqvrmtivmljujwocp.supabase.co
```

**However**, the *actual* Supabase instance being used depends on the environment variables set in **Lovable's deployment environment**.

---

## Step-by-Step Guide to Find Your Live Supabase Connection

### Method 1: Check the Running App (Easiest & Most Accurate)

This is the **best way** to verify which Supabase instance your live app is using:

1. **Open your Lovable app** in a web browser
2. **Navigate to the Settings/Debug page**: Go to `/settings` in your app URL
   - Example: `https://your-app.lovable.app/settings`
   - You should see a "Supabase Connection Info" section
3. **Check the displayed information**:
   - **Project ID**: The actual project being used
   - **Project URL**: The Supabase endpoint
   - **Connection Status**: Whether the connection is working

4. **Verify in Supabase Dashboard**:
   - Copy the Project ID shown in the app
   - Go to https://supabase.com/dashboard
   - Find the project with matching ID
   - This is your live Supabase instance!

### Method 2: Check Lovable Environment Variables

Lovable stores the Supabase configuration in environment variables:

1. **Open your Lovable project**
   - Go to https://lovable.dev
   - Select your project: "oricol-ticket-flow-34e64301"

2. **Go to Project Settings**
   - Click the **Settings** icon (⚙️) or gear icon
   - Look for **"Environment Variables"** or **"Integrations"** section

3. **Find these variables**:
   ```
   VITE_SUPABASE_URL
   VITE_SUPABASE_PUBLISHABLE_KEY
   VITE_SUPABASE_PROJECT_ID
   ```

4. **Check the values**:
   - The `VITE_SUPABASE_PROJECT_ID` tells you which project is being used
   - The `VITE_SUPABASE_URL` should match: `https://[PROJECT_ID].supabase.co`

### Method 3: Check Lovable Integrations Tab

1. **In your Lovable project**, look for an **"Integrations"** tab
2. **Find the Supabase integration**:
   - If you see Supabase listed, click on it
   - It should show which Supabase project is connected
   - Note: The project name and ID should be displayed

3. **Compare with your Supabase projects**:
   - Go to https://supabase.com/dashboard
   - Check if the connected project exists in your account
   - If it doesn't, Lovable may have created an auto-provisioned project

### Method 4: Browser Developer Console (Technical)

If you can't access the Settings page or Lovable dashboard:

1. **Open your Lovable app** in a browser
2. **Open Developer Tools**:
   - Press `F12` or `Cmd+Option+I` (Mac) / `Ctrl+Shift+I` (Windows/Linux)
3. **Go to the Console tab**
4. **Type and run**:
   ```javascript
   console.log('Supabase URL:', import.meta.env.VITE_SUPABASE_URL)
   console.log('Supabase Project ID:', import.meta.env.VITE_SUPABASE_PROJECT_ID)
   ```
5. **Check the output** - this shows the actual configuration being used

---

## Understanding Your Supabase Setup

### Scenario 1: Lovable Auto-Provisioned Supabase ✨

**What happened:**
- When you created your Lovable project, it automatically created a Supabase project for you
- This Supabase project is managed by Lovable
- It may not appear in your personal Supabase dashboard initially

**How to verify:**
- Check if the Project ID matches `kwmeqvrmtivmljujwocp`
- If you can't find this project in https://supabase.com/dashboard, it was auto-provisioned

**What to do:**
- Lovable should have granted you access to this project
- Check your email for Supabase invitations
- Or, contact Lovable support to get access

### Scenario 2: You Manually Connected Your Own Supabase 🔗

**What happened:**
- You added a Supabase integration in Lovable's Integrations tab
- You connected it to your existing Supabase project

**How to verify:**
- The Project ID should match one of your Supabase projects
- You should have full access in https://supabase.com/dashboard

**What to do:**
- Ensure environment variables in Lovable match your Supabase project
- Verify the connection is using the correct project

### Scenario 3: Conflicting Supabase Connections ⚠️

**What happened:**
- Lovable created an auto-provisioned Supabase project
- You later added a different Supabase project in Integrations
- The app might be using one while you're managing the other

**How to verify:**
- Check environment variables in Lovable (they determine what's used)
- Compare with the Integration you added manually

**What to do:**
1. **Decide which Supabase to use** (auto-provisioned vs. your own)
2. **Update environment variables** to match your choice
3. **Run migrations** on the correct Supabase instance

---

## Common Issues and Solutions

### Issue 1: "I can't find my Supabase project"

**Solution:**
- The project ID is `kwmeqvrmtivmljujwocp`
- Search for this in https://supabase.com/dashboard
- If not found, check your email for Supabase invitations
- Contact Lovable support if you need access

### Issue 2: "I added a Supabase integration but the app isn't using it"

**Solution:**
- Adding an integration doesn't automatically update environment variables
- Go to Lovable Settings → Environment Variables
- Update these variables to point to your Supabase project:
  ```
  VITE_SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
  VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key-from-supabase
  VITE_SUPABASE_PROJECT_ID=YOUR-PROJECT-ID
  ```
- Redeploy the app in Lovable

### Issue 3: "My Supabase project doesn't have the right tables/data"

**Solution:**
- You're probably connected to the wrong Supabase project
- Use Method 1 (Settings page) to verify which project is being used
- Run migrations on the correct project:
  ```bash
  npx supabase link --project-ref YOUR-PROJECT-ID
  npx supabase db push
  ```

### Issue 4: "Changes in Supabase dashboard aren't reflected in the app"

**Solution:**
- Verify you're editing the correct Supabase project
- Check the Project ID matches the one used by your app
- The app caches data - try hard refresh (`Ctrl+Shift+R` or `Cmd+Shift+R`)

---

## How to Switch to a Different Supabase Project

If you want to use a different Supabase project:

### Option A: Update Lovable Environment Variables

1. **Get your Supabase credentials**:
   - Go to https://supabase.com/dashboard
   - Select your project
   - Go to **Settings → API**
   - Copy:
     - Project URL
     - Project ID  
     - `anon` public key

2. **Update Lovable environment variables**:
   - In Lovable, go to Settings → Environment Variables
   - Update:
     ```
     VITE_SUPABASE_URL=https://YOUR-PROJECT-ID.supabase.co
     VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key
     VITE_SUPABASE_PROJECT_ID=YOUR-PROJECT-ID
     ```

3. **Redeploy in Lovable**

### Option B: Update Repository Configuration

1. **Update `.env` file**:
   ```bash
   VITE_SUPABASE_PROJECT_ID="your-new-project-id"
   VITE_SUPABASE_PUBLISHABLE_KEY="your-new-anon-key"
   VITE_SUPABASE_URL="https://your-new-project-id.supabase.co"
   ```

2. **Update `supabase/config.toml`**:
   ```toml
   project_id = "your-new-project-id"
   ```

3. **Push changes to GitHub**
   - Lovable will sync automatically

4. **Run migrations on new project**:
   ```bash
   npx supabase link --project-ref your-new-project-id
   npx supabase db push
   ```

---

## Next Steps

1. ✅ **Use Method 1** (Settings page) to verify your current Supabase connection
2. ✅ **Log into Supabase dashboard** and find the project being used
3. ✅ **Verify migrations are applied** to the correct project
4. ✅ **Test your app** to ensure everything works

---

## Still Having Issues?

### Check these resources:
- **Lovable Documentation**: https://docs.lovable.dev
- **Supabase Documentation**: https://supabase.com/docs
- **This Repository's Guides**:
  - [VERIFY_SUPABASE_CONNECTION.md](./VERIFY_SUPABASE_CONNECTION.md)
  - [SETUP.md](./SETUP.md)
  - [LOCAL_SETUP.md](./LOCAL_SETUP.md)

### Get help:
- **Lovable Support**: Contact via Lovable dashboard
- **Supabase Support**: https://supabase.com/support
- **GitHub Issues**: Open an issue in this repository

---

## Quick Reference

### Your Current Configuration

```
Repository: oricol-ticket-flow-34e64301
Project ID: kwmeqvrmtivmljujwocp
Supabase URL: https://kwmeqvrmtivmljujwocp.supabase.co
```

### Where Settings Are Stored

1. **Live app environment**: Lovable environment variables (controls what users see)
2. **Repository**: `.env` file (for local development)
3. **Supabase CLI**: `supabase/config.toml` (for migrations)

### Important: Which One Matters?

- **For the live Lovable app**: Lovable's environment variables are the source of truth
- **For local development**: `.env` file is used
- **For database migrations**: `supabase/config.toml` determines target project
