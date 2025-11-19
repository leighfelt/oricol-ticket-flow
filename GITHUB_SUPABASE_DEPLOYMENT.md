# GitHub + Supabase Deployment Guide

This guide explains how to deploy the Oricol Helpdesk app using **GitHub** for version control and CI/CD, and **Supabase** for the backend.

## Overview

The app can be run completely independently using:
- **GitHub**: Source code management, CI/CD with GitHub Actions
- **Supabase**: Backend database, authentication, and storage
- **Hosting**: GitHub Pages, Netlify, Vercel, or Cloudflare Pages (all free options available)

## Prerequisites

1. **GitHub Account** (free) - [github.com](https://github.com)
2. **Supabase Account** (free tier available) - [supabase.com](https://supabase.com)
3. **Node.js 18+** installed locally - [nodejs.org](https://nodejs.org)

## Step 1: Fork or Clone the Repository

### Option A: Fork to Your GitHub Account
1. Go to the repository on GitHub
2. Click the "Fork" button in the top right
3. This creates a copy under your GitHub account

### Option B: Clone Directly
```bash
git clone https://github.com/craigfelt/oricol-ticket-flow-4084ab4c.git
cd oricol-ticket-flow-4084ab4c
```

## Step 2: Set Up Supabase Backend

### 1. Create a Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Sign up for free (no credit card required)
3. Click "New Project"
4. Enter project details:
   - **Name**: oricol-helpdesk (or your choice)
   - **Database Password**: (save this securely)
   - **Region**: Choose closest to your users
5. Wait ~2 minutes for project creation

### 2. Get Your Supabase Credentials
1. In your Supabase project dashboard
2. Go to **Settings** → **API**
3. Copy the following:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public** key (long JWT token)
   - **Project Reference ID** (found in Settings → General)

### 3. Apply Database Migrations

You have two options:

#### Option A: Using Supabase CLI (Recommended)
```bash
# Install Supabase CLI globally
npm install -g supabase

# Link to your project
npx supabase link --project-ref YOUR_PROJECT_REF

# Push all migrations
npx supabase db push
```

#### Option B: Manual SQL Execution
1. Go to your Supabase project
2. Click **SQL Editor** in the left sidebar
3. Run each migration file from `supabase/migrations/` in chronological order
4. Files are named with timestamps - run them oldest to newest

## Step 3: Configure Environment Variables

### For Local Development

Create a `.env` file in the project root:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key-here
VITE_SUPABASE_PROJECT_ID=your-project-ref
```

### For GitHub Actions (Production)

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these three secrets:
   - `VITE_SUPABASE_URL`: Your Supabase project URL
   - `VITE_SUPABASE_PUBLISHABLE_KEY`: Your anon/public key
   - `VITE_SUPABASE_PROJECT_ID`: Your project reference ID

## Step 4: Test Locally

```bash
# Install dependencies
npm install

# Start development server
npm run dev

# App will be available at http://localhost:8080
```

## Step 5: Choose Your Deployment Method

### Option A: GitHub Pages (Easiest)

**Setup:**
1. Enable GitHub Pages in your repository settings:
   - Go to **Settings** → **Pages**
   - Source: **GitHub Actions**
2. The workflow is already configured in `.github/workflows/deploy-github-pages.yml`
3. Push to `main` branch to trigger deployment

**Note**: GitHub Pages serves from a subdirectory, so you may need to update your app's routing if using React Router.

### Option B: Netlify (Recommended for Production)

**Setup:**
1. Go to [netlify.com](https://netlify.com)
2. Sign up for free
3. Click **Add new site** → **Import an existing project**
4. Connect to your GitHub repository
5. Configure build settings:
   - **Build command**: `npm run build`
   - **Publish directory**: `dist`
6. Add environment variables in Netlify:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`
   - `VITE_SUPABASE_PROJECT_ID`
7. Deploy!

**Using GitHub Actions** (optional):
1. Get your Netlify site ID and auth token:
   - Site ID: Found in Site Settings
   - Auth token: User Settings → Applications → New access token
2. Add to GitHub secrets:
   - `NETLIFY_SITE_ID`
   - `NETLIFY_AUTH_TOKEN`
3. Enable the workflow in `.github/workflows/deploy-netlify.yml`

### Option C: Vercel

**Setup:**
1. Go to [vercel.com](https://vercel.com)
2. Sign up for free
3. Click **Add New** → **Project**
4. Import your GitHub repository
5. Configure:
   - **Framework Preset**: Vite
   - **Build Command**: `npm run build`
   - **Output Directory**: `dist`
6. Add environment variables
7. Deploy!

### Option D: Cloudflare Pages

**Setup:**
1. Go to [pages.cloudflare.com](https://pages.cloudflare.com)
2. Sign up for free
3. Click **Create a project**
4. Connect to your GitHub repository
5. Configure:
   - **Build command**: `npm run build`
   - **Build output directory**: `dist`
6. Add environment variables
7. Deploy!

## Step 6: Continuous Deployment

Once set up, your app will automatically redeploy when you:
1. Push code to the `main` branch on GitHub
2. Merge a pull request into `main`

### GitHub Actions Workflows

The repository includes several workflows:

1. **CI Workflow** (`.github/workflows/ci.yml`):
   - Runs on every push and PR
   - Tests build on Node 18 and 20
   - Runs linter
   - Uploads build artifacts

2. **GitHub Pages Deployment** (`.github/workflows/deploy-github-pages.yml`):
   - Deploys to GitHub Pages on push to main
   - Can be triggered manually

3. **Netlify Deployment** (`.github/workflows/deploy-netlify.yml`):
   - Deploys to Netlify on push to main
   - Requires Netlify secrets configured

## Database Management

### Running New Migrations

When database schema changes are needed:

```bash
# Create a new migration
npx supabase migration new migration_name

# Edit the generated file in supabase/migrations/

# Apply locally (if using local Supabase)
npx supabase db reset

# Apply to production
npx supabase db push
```

### Backup and Restore

**Backup:**
```bash
# Backup your database
npx supabase db dump -f backup.sql
```

**Restore:**
```bash
# Restore from backup
npx supabase db reset --db-url "postgresql://..."
```

## Monitoring and Maintenance

### Supabase Dashboard
- Monitor database usage
- View API requests
- Check authentication logs
- Manage storage

### GitHub Actions
- View build/deployment status
- Check logs for errors
- Monitor deployment history

## Troubleshooting

### Build Fails in GitHub Actions

**Issue**: Build fails with environment variable errors

**Solution**: Ensure all secrets are set in GitHub repository settings

### Database Connection Issues

**Issue**: App can't connect to Supabase

**Solution**:
1. Verify environment variables are correct
2. Check Supabase project is active (free tier pauses after 7 days)
3. Verify API keys haven't been rotated

### Deployment Takes Too Long

**Issue**: GitHub Actions workflow times out

**Solution**:
1. Check if `npm ci` is being used (faster than `npm install`)
2. Verify no unnecessary dependencies are being installed
3. Consider using caching in GitHub Actions

## Security Best Practices

1. **Never commit `.env` files** - They're in `.gitignore`
2. **Use GitHub Secrets** for production environment variables
3. **Rotate Supabase keys** if they're ever exposed
4. **Enable Row Level Security (RLS)** in Supabase
5. **Review Supabase auth settings** regularly

## Cost Breakdown

### Free Tier Limits

**Supabase Free Tier:**
- 500MB database storage
- 2GB bandwidth/month
- 50MB file storage
- Unlimited API requests
- Auto-pauses after 7 days inactivity

**GitHub:**
- Unlimited public repositories
- 2,000 GitHub Actions minutes/month
- 500MB package storage

**Hosting (varies by provider):**
- **Netlify**: 100GB bandwidth/month
- **Vercel**: 100GB bandwidth/month
- **Cloudflare Pages**: Unlimited bandwidth
- **GitHub Pages**: 100GB bandwidth/month

**Total Cost**: $0/month (within free tier limits)

## Scaling Beyond Free Tier

If you outgrow the free tier:

**Supabase Pro** ($25/month):
- 8GB database storage
- 50GB bandwidth
- 100GB file storage
- No auto-pause

**Hosting** (if needed):
- Most apps stay within free tier limits
- Paid tiers typically start at $5-20/month

## Next Steps

1. ✅ Set up Supabase project
2. ✅ Configure GitHub repository
3. ✅ Deploy to your chosen platform
4. ✅ Test the deployed application
5. ✅ Set up monitoring and alerts
6. ✅ Configure custom domain (optional)

## Support

For issues:
- **Supabase**: [supabase.com/docs](https://supabase.com/docs)
- **GitHub Actions**: [docs.github.com/actions](https://docs.github.com/actions)
- **Deployment Platform**: Check their respective documentation
- **This App**: Open an issue on GitHub

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [GitHub Actions Documentation](https://docs.github.com/actions)
- [Vite Deployment Guide](https://vitejs.dev/guide/static-deploy.html)
- [React Deployment Guide](https://react.dev/learn/start-a-new-react-project#deploying-to-production)
