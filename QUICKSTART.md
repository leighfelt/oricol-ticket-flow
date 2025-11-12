# 🚀 Quick Reference Card

## Running Locally (Free - No Cloud)

```bash
# 1. Install dependencies
npm install

# 2. Start local Supabase (requires Docker)
npx supabase start

# 3. Copy the anon key from output, create .env.local:
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<anon-key-from-step-2>

# 4. Start app
npm run dev

# Access:
# - App: http://localhost:8080
# - Database Admin: http://localhost:54323
# - Email Testing: http://localhost:54324
```

## Using Supabase Free Tier (Cloud)

```bash
# 1. Install dependencies
npm install

# 2. Create free account at supabase.com

# 3. Create new project, get credentials

# 4. Create .env:
VITE_SUPABASE_URL=<your-project-url>
VITE_SUPABASE_PUBLISHABLE_KEY=<your-anon-key>

# 5. Link and push migrations
npx supabase link --project-ref <your-ref>
npx supabase db push

# 6. Start app
npm run dev
```

## Deploy to Production (Free)

```bash
# Build
npm run build

# Deploy to Netlify (free)
# Drag & drop the 'dist' folder to netlify.com

# OR deploy to Vercel (free)
npx vercel --prod

# OR deploy to Cloudflare Pages (free)
# Connect your GitHub repo at pages.cloudflare.com
```

## Common Commands

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm run preview          # Preview production build
npm run lint             # Run linter

# Supabase (Local)
npx supabase start       # Start local instance
npx supabase stop        # Stop local instance
npx supabase status      # Check status
npx supabase db reset    # Reset database (WARNING: deletes data)

# Supabase (Cloud)
npx supabase link        # Link to cloud project
npx supabase db push     # Push migrations
npx supabase db pull     # Pull schema changes
```

## Need Help?

- **Local Setup**: See [LOCAL_SETUP.md](./LOCAL_SETUP.md)
- **Deployment**: See [DEPLOYMENT.md](./DEPLOYMENT.md)
- **Full Guide**: See [README.md](./README.md)

## Free Tier Limits

### Supabase Free Tier
- ✅ 500MB database storage
- ✅ 2GB bandwidth/month
- ✅ 50MB file storage
- ✅ Unlimited API requests
- ⚠️ Pauses after 7 days of inactivity (easily resumed)

### Netlify Free Tier
- ✅ 100GB bandwidth/month
- ✅ 300 build minutes/month
- ✅ Automatic HTTPS

### Vercel Free Tier
- ✅ 100GB bandwidth/month
- ✅ Automatic deployments
- ✅ Custom domains

### Cloudflare Pages Free Tier
- ✅ Unlimited bandwidth
- ✅ 500 builds/month
- ✅ Custom domains
