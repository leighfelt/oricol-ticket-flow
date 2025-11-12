# 🎯 Complete Setup Guide - Choose Your Path

## 🌟 You Have 3 Options (All Free!)

### Option 1: Local Development Only (Best for Testing)
**Cost**: $0  
**Requires**: Docker Desktop  
**Best for**: Learning, testing, development  

### Option 2: Supabase Free Tier + Free Hosting (Best for Production)
**Cost**: $0  
**Requires**: Free Supabase account  
**Best for**: Production apps, small teams  

### Option 3: Fully Self-Hosted (Advanced)
**Cost**: $0  
**Requires**: Your own server  
**Best for**: Complete control, privacy  

---

## 🚀 Option 1: Local Development (Fastest Start)

**What you get:**
- Full PostgreSQL database on your computer
- Authentication system
- Database admin UI
- Email testing tool

**Requirements:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop) (free)
- Node.js 18+

**Setup (5 minutes):**

```bash
# 1. Clone and install
git clone https://github.com/craigfelt/oricol-ticket-flow-34e64301.git
cd oricol-ticket-flow-34e64301
npm install

# 2. Start local Supabase (first time takes ~5 min to download images)
npx supabase start

# 3. Save the output! It contains your credentials
# Look for: "anon key: eyJh..."

# 4. Create .env.local file
cat > .env.local << EOF
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<paste-anon-key-here>
EOF

# 5. Start the app
npm run dev
```

**Access:**
- 🌐 App: http://localhost:8080
- 🗄️ Database Admin: http://localhost:54323
- 📧 Email Testing: http://localhost:54324

**Helpful commands:**
```bash
npx supabase stop              # Stop when done
npx supabase start             # Start again
npx supabase status            # Check if running
npx supabase db reset          # Reset database (deletes all data)
```

---

## ☁️ Option 2: Supabase Free Tier (Production Ready)

**What you get:**
- 500MB PostgreSQL database
- 2GB bandwidth/month
- 50MB file storage
- Unlimited API requests
- Production-ready hosting

**Requirements:**
- Free Supabase account ([supabase.com](https://supabase.com))
- Free hosting account (Netlify/Vercel/Cloudflare)

**Setup (10 minutes):**

### A. Backend Setup (Supabase)

```bash
# 1. Clone and install
git clone https://github.com/craigfelt/oricol-ticket-flow-34e64301.git
cd oricol-ticket-flow-34e64301
npm install

# 2. Create Supabase project
# - Go to supabase.com
# - Sign up (free, no credit card)
# - Click "New Project"
# - Wait 2 minutes for setup

# 3. Get credentials
# In your Supabase project:
# - Go to Settings > API
# - Copy "Project URL"
# - Copy "anon public" key
# - Copy "Project Ref" (from URL)

# 4. Create .env file
cat > .env << EOF
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key
VITE_SUPABASE_PROJECT_ID=your-project-ref
EOF

# 5. Link project and push migrations
npx supabase link --project-ref your-project-ref
npx supabase db push

# 6. Test locally
npm run dev
```

### B. Frontend Setup (Choose One)

**Option B1: Netlify (Easiest)**
```bash
# Build the app
npm run build

# Go to netlify.com
# Sign up (free)
# Drag & drop the 'dist' folder
# Done! Your app is live
```

**Option B2: Vercel**
```bash
# Build and deploy
npm run build
npx vercel --prod

# Follow prompts, done!
```

**Option B3: Cloudflare Pages**
```bash
# 1. Push code to GitHub
# 2. Go to pages.cloudflare.com
# 3. Connect your repo
# 4. Build command: npm run build
# 5. Output directory: dist
# Done!
```

---

## 🏠 Option 3: Fully Self-Hosted (Advanced)

**What you get:**
- Complete control
- No external dependencies
- Privacy

**Requirements:**
- Your own Linux server or VPS
- Docker installed on server

**Setup:**

See [DEPLOYMENT.md](./DEPLOYMENT.md#deploying-self-hosted-supabase-to-production) for complete instructions.

Quick version:
```bash
# On your server
git clone https://github.com/craigfelt/oricol-ticket-flow-34e64301.git
cd oricol-ticket-flow-34e64301
docker-compose up -d
npm run build
# Serve 'dist' folder with nginx/apache
```

---

## 📊 Comparison

| Feature | Local Dev | Supabase Free | Self-Hosted |
|---------|-----------|---------------|-------------|
| **Cost** | $0 | $0 | $0* |
| **Setup Time** | 5 min | 10 min | 30+ min |
| **Internet Required** | No | Yes | No |
| **Scalability** | Low | High | Medium |
| **Best For** | Development | Production | Privacy |

*Self-hosted costs depend on your server choice

---

## 🆘 Troubleshooting

### Local Development Issues

**"Docker not found"**
- Install [Docker Desktop](https://www.docker.com/products/docker-desktop)

**"Port already in use"**
```bash
npx supabase stop
docker ps -a  # Check what's running
```

**"Containers won't start"**
```bash
npx supabase stop --no-backup
docker system prune -a  # Warning: removes all Docker images
npx supabase start
```

### Supabase Free Tier Issues

**"Database paused"**
- Free tier pauses after 7 days inactivity
- Just visit your app, it wakes up in ~10 seconds

**"Too many requests"**
- Free tier has rate limits
- Implement caching or upgrade

**"Out of storage"**
- Free tier: 500MB limit
- Clean up old data or upgrade

---

## 📚 Next Steps

1. ✅ Choose your option above
2. ✅ Follow the setup steps
3. ✅ Create your first user account
4. ✅ Create a test ticket
5. ✅ Explore the features!

**Need more help?**
- 📖 [QUICKSTART.md](./QUICKSTART.md) - Quick reference
- 🔧 [LOCAL_SETUP.md](./LOCAL_SETUP.md) - Detailed local setup
- 🚀 [DEPLOYMENT.md](./DEPLOYMENT.md) - Production deployment
- 📘 [README.md](./README.md) - Full documentation

---

## 💡 Recommended Path

**For beginners:**
1. Start with **Option 1 (Local Development)** to learn
2. Move to **Option 2 (Supabase Free Tier)** for production

**For production immediately:**
- Use **Option 2 (Supabase Free Tier + Netlify)**

**For maximum control:**
- Use **Option 3 (Self-Hosted)**

---

## 🎉 Success Checklist

After setup, you should be able to:

- [ ] Access the login page
- [ ] Create a user account
- [ ] Sign in
- [ ] See the dashboard
- [ ] Create a ticket
- [ ] View tickets list

If all checkboxes work, you're done! 🎊
