# Quick Start: GitHub + Supabase Deployment

## 🎯 What Changed

This app has been migrated from Lovable to an independent GitHub + Supabase setup. You now have:

✅ **Full control** - Host anywhere, no platform lock-in  
✅ **Automated CI/CD** - GitHub Actions handles builds and deployments  
✅ **Free hosting** - Multiple free tier options available  
✅ **Iframe support** - Embed on your website  

## 🚀 5-Minute Quick Start

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com) and sign up (free)
2. Create new project (takes ~2 minutes)
3. Copy these from Settings → API:
   - Project URL
   - anon/public key
   - Project Reference ID

### 2. Apply Database Migrations
```bash
# Install Supabase CLI
npm install -g supabase

# Link to your project
npx supabase link --project-ref YOUR_PROJECT_REF

# Apply all migrations
npx supabase db push
```

### 3. Deploy to Netlify (Easiest)
1. Go to [netlify.com](https://netlify.com)
2. Click "Add new site" → Import from Git
3. Connect your GitHub repository
4. Add environment variables:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_PUBLISHABLE_KEY`
   - `VITE_SUPABASE_PROJECT_ID`
5. Deploy!

**Your app is now live!** 🎉

## 📦 What's Included

### GitHub Actions Workflows
- **CI Pipeline** (`.github/workflows/ci.yml`)
  - Runs on every push and PR
  - Tests build on Node 18 and 20
  - Runs linter
  
- **GitHub Pages Deploy** (`.github/workflows/deploy-github-pages.yml`)
  - Auto-deploys to GitHub Pages on push to main
  
- **Netlify Deploy** (`.github/workflows/deploy-netlify.yml`)
  - Auto-deploys to Netlify on push to main

### Configuration Files
- `netlify.toml` - Netlify deployment config with iframe support
- `vercel.json` - Vercel deployment config with iframe support
- `public/_headers` - Security headers for iframe embedding

### Documentation
- `GITHUB_SUPABASE_DEPLOYMENT.md` - Complete deployment guide
- `IFRAME_SETUP.md` - Embed app on your website
- `iframe-examples.html` - Live examples

## 🌐 Embedding as Iframe

### Basic Iframe
```html
<iframe 
  src="https://your-deployed-app.com" 
  width="100%" 
  height="800px"
  frameborder="0"
  title="Helpdesk"
></iframe>
```

### Widget Style (Recommended)
```html
<!-- Floating button in corner -->
<div class="helpdesk-widget">
  <button onclick="toggleHelpdesk()">💬 Need Help?</button>
  <div id="helpdesk-container" style="display:none;">
    <iframe src="https://your-deployed-app.com"></iframe>
  </div>
</div>
```

See `IFRAME_SETUP.md` for complete guide and examples.

## 🔧 Configuration Steps

### For Iframe Embedding

1. **Update headers** - Edit `netlify.toml` or `vercel.json`:
   ```
   Content-Security-Policy: frame-ancestors 'self' https://yourdomain.com
   ```

2. **Configure Supabase** - Add your website domain to:
   - Authentication → URL Configuration → Site URL
   - Add redirect URLs for your domain

3. **Test** - Open `iframe-examples.html` in a browser

## 🆓 Deployment Options

| Platform | Cost | Bandwidth | Setup Time |
|----------|------|-----------|------------|
| **Supabase** | Free | 2GB/month | 2 min |
| **Netlify** | Free | 100GB/month | 5 min |
| **Vercel** | Free | 100GB/month | 5 min |
| **GitHub Pages** | Free | 100GB/month | 10 min |
| **Cloudflare** | Free | Unlimited | 10 min |

**Total: $0/month** (within free tier limits)

## 📝 Environment Variables

Required for deployment:

```env
VITE_SUPABASE_URL=https://xxxxx.supabase.co
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGci...
VITE_SUPABASE_PROJECT_ID=xxxxx
```

### Where to Add Them:

**GitHub (for GitHub Actions)**:
- Settings → Secrets and variables → Actions
- Add as Repository secrets

**Netlify**:
- Site settings → Environment variables

**Vercel**:
- Project settings → Environment Variables

## 🎓 Learning Resources

### For Deployment:
- [GITHUB_SUPABASE_DEPLOYMENT.md](./GITHUB_SUPABASE_DEPLOYMENT.md) - Step-by-step guide
- [Supabase Docs](https://supabase.com/docs)
- [GitHub Actions Docs](https://docs.github.com/actions)

### For Iframe Integration:
- [IFRAME_SETUP.md](./IFRAME_SETUP.md) - Complete iframe guide
- [iframe-examples.html](./iframe-examples.html) - Live examples

### For Development:
- [README.md](./README.md) - Full documentation
- [LOCAL_SETUP.md](./LOCAL_SETUP.md) - Local development

## 🆘 Common Issues

### Build fails
**Solution**: Check that all environment variables are set correctly

### Database connection fails
**Solution**: Verify Supabase credentials and that project is active

### Iframe doesn't load
**Solution**: Check CSP headers in `netlify.toml` or `vercel.json`

### Authentication in iframe fails
**Solution**: Configure Supabase redirect URLs to include your domain

## 🎯 Next Steps

1. ✅ Deploy to Supabase + Netlify (5 minutes)
2. ✅ Test the deployed app
3. ✅ (Optional) Embed as iframe on your website
4. ✅ (Optional) Configure custom domain

## 📞 Support

- **Issues**: Open a GitHub issue
- **Documentation**: See the guides linked above
- **Supabase Help**: [supabase.com/docs](https://supabase.com/docs)

---

**You're all set!** 🚀 The app now runs independently on GitHub + Supabase.
