# Deployment Guide - Free Hosting Options

This guide explains how to deploy the Oricol Helpdesk app **completely free** without paying for Supabase or Vercel premium plans.

## Option 1: Free Supabase Tier (Recommended for Beginners)

Supabase offers a **generous free tier** that includes:
- Up to 500MB database storage
- Up to 2GB bandwidth
- Up to 50MB file storage
- Unlimited API requests
- Pausable after 7 days of inactivity (easily resumed)

### Setup Steps:

1. **Create Free Supabase Account**
   - Go to [supabase.com](https://supabase.com)
   - Sign up for free (no credit card required)
   - Create a new project

2. **Configure Environment Variables**
   - Copy your Supabase project URL and anon key
   - Update `.env` file:
     ```env
     VITE_SUPABASE_URL=your_project_url
     VITE_SUPABASE_PUBLISHABLE_KEY=your_anon_key
     VITE_SUPABASE_PROJECT_ID=your_project_id
     ```

3. **Run Database Migrations**
   ```bash
   npx supabase link --project-ref your_project_ref
   npx supabase db push
   ```

4. **Deploy Frontend**
   - See "Frontend Hosting Options" below

---

## Option 2: Self-Hosted Supabase (Completely Free, Local Development)

Run Supabase locally using Docker - **100% free**, no external dependencies.

### Prerequisites:
- Docker Desktop installed ([download here](https://www.docker.com/products/docker-desktop))
- 4GB+ RAM available

### Setup Steps:

1. **Install Supabase CLI**
   ```bash
   npx supabase init
   ```

2. **Start Local Supabase**
   ```bash
   npx supabase start
   ```
   
   This command will:
   - Start PostgreSQL database
   - Start authentication service
   - Start storage service
   - Apply all migrations automatically
   - Output local credentials

3. **Update Environment Variables**
   ```env
   VITE_SUPABASE_URL=http://localhost:54321
   VITE_SUPABASE_PUBLISHABLE_KEY=<key from supabase start output>
   ```

4. **Run the App**
   ```bash
   npm run dev
   ```

### Deploying Self-Hosted Supabase to Production:

For production, deploy Supabase to free hosting platforms:

#### Railway.app (Free Tier)
- 500 hours/month free
- Persistent storage
- PostgreSQL included
  
```bash
# 1. Create account at railway.app
# 2. Install Railway CLI
npm install -g @railway/cli

# 3. Deploy
railway login
railway init
railway up
```

#### Render.com (Free Tier)
- Free PostgreSQL database
- Auto-deploys from GitHub
- 750 hours/month free

```bash
# Deploy PostgreSQL + Web Service
# Follow: https://render.com/docs/deploy-postgresql
```

---

## Option 3: Alternative Backend - PocketBase (Ultra Lightweight)

PocketBase is a single-file backend that's even easier than Supabase.

### Why PocketBase?
- Single executable file (~15MB)
- Built-in admin UI
- Free forever
- No Docker required
- SQLite database

### Setup Steps:

1. **Download PocketBase**
   ```bash
   # Download from https://pocketbase.io/docs/
   wget https://github.com/pocketbase/pocketbase/releases/download/v0.22.0/pocketbase_0.22.0_linux_amd64.zip
   unzip pocketbase_0.22.0_linux_amd64.zip
   ```

2. **Run PocketBase**
   ```bash
   ./pocketbase serve
   ```
   
   Access admin at: http://localhost:8090/_/

3. **Migrate Code** (requires changes to Supabase client calls)
   - Replace `@supabase/supabase-js` with PocketBase SDK
   - Update authentication logic
   - Update database queries

---

## Frontend Hosting Options (All Free)

### 1. GitHub Pages (Static Hosting)
**Cost**: Free  
**Limits**: 100GB bandwidth/month, 1GB storage

```bash
npm run build
# Use gh-pages branch or GitHub Actions
```

### 2. Netlify (Free Tier)
**Cost**: Free  
**Limits**: 100GB bandwidth/month, 300 build minutes/month

```bash
# Connect GitHub repo to Netlify
# Auto-deploys on push
```

Build settings:
- Build command: `npm run build`
- Publish directory: `dist`

### 3. Vercel (Free Tier - No Premium Required)
**Cost**: Free  
**Limits**: 100GB bandwidth/month

```bash
npm install -g vercel
vercel --prod
```

### 4. Cloudflare Pages (Free)
**Cost**: Free  
**Limits**: Unlimited bandwidth, 500 builds/month

```bash
# Connect GitHub repo
# Auto-deploys on push
```

### 5. Firebase Hosting (Free Tier)
**Cost**: Free  
**Limits**: 10GB storage, 360MB/day bandwidth

```bash
npm install -g firebase-tools
firebase init hosting
firebase deploy
```

---

## Recommended Setup for $0 Cost

**Best Free Stack:**

1. **Database**: Supabase Free Tier OR Local Supabase
2. **Hosting**: Netlify Free Tier OR GitHub Pages
3. **Total Cost**: $0/month

**Production Stack** (Free but more robust):

1. **Database**: Self-hosted Supabase on Railway.app
2. **Frontend**: Cloudflare Pages
3. **Total Cost**: $0/month (within free tier limits)

---

## Current Setup

This repository is already configured with:
- ✅ Supabase integration (can use free tier)
- ✅ All database migrations
- ✅ Environment variables template
- ✅ Build scripts for static deployment

**Quick Start** (Using Supabase Free Tier):

```bash
# 1. Create free Supabase account
# 2. Create new project
# 3. Update .env with your credentials
# 4. Push migrations: npx supabase db push
# 5. Deploy to Netlify/Vercel/GitHub Pages
```

---

## Troubleshooting

### "Too many requests" on free tier
- Free tier has rate limits
- Solution: Implement request caching or upgrade

### Database paused after 7 days
- Free tier databases pause after inactivity
- Solution: Make a request to wake it up (takes ~10 seconds)

### Out of storage
- Free tier: 500MB database + 50MB files
- Solution: Clean up old data or upgrade

---

## Support

For issues:
1. Check [Supabase docs](https://supabase.com/docs)
2. Check hosting platform docs
3. Open an issue in this repository
