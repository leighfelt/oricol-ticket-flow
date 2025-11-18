# Local Development Setup - No Cloud Required

This guide shows you how to run the Oricol Helpdesk app **100% locally** on your computer without any cloud services or Lovable.

## ⚡ Quick Start (5 Minutes)

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running
- Node.js 18+ installed ([install with nvm](https://github.com/nvm-sh/nvm))
- 4GB+ RAM available

### Step-by-Step Setup

**1. Clone and Install Dependencies**
```bash
git clone https://github.com/craigfelt/oricol-ticket-flow-34e64301.git
cd oricol-ticket-flow-34e64301
npm install
```

**2. Start Local Supabase (This starts PostgreSQL database locally)**
```bash
npx supabase start
```

**Wait for it to complete** - This takes 1-2 minutes. You'll see output like:
```
✔ Started supabase local development setup.

         API URL: http://localhost:54321
     GraphQL URL: http://localhost:54321/graphql/v1
          DB URL: postgresql://postgres:postgres@localhost:54322/postgres
      Studio URL: http://localhost:54323
    Inbucket URL: http://localhost:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**3. Set Up Database Schema**

Open Supabase Studio in your browser:
```bash
# Open this URL in your browser:
http://localhost:54323
```

In Supabase Studio:
- Click **"SQL Editor"** in the left sidebar
- Click **"New query"**
- Open the file `LOCAL_SETUP_COMPLETE.sql` from your project folder
- Copy and paste **the entire contents** into the SQL editor
- Click **"Run"** button

You should see success messages confirming all tables were created!

**4. Create Environment File**

Create a file named `.env.local` in your project root:
```env
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<paste-the-anon-key-from-step-2>
```

**Important:** Copy the `anon key` value from step 2 output and paste it after `VITE_SUPABASE_PUBLISHABLE_KEY=`

**5. Start the Application**
```bash
npm run dev
```

**6. Access Your App**
- **Application:** http://localhost:8080
- **Database Admin:** http://localhost:54323
- **Email Testing:** http://localhost:54324

## ✅ That's It!

You now have a **fully local** Oricol Helpdesk running on your computer with:
- ✅ PostgreSQL database (no cloud)
- ✅ Full authentication system
- ✅ All features working
- ✅ No internet required (after initial setup)
- ✅ No Lovable needed
- ✅ No cloud costs

---

## 📋 Using Your Local Setup

### First Time Login
1. Go to http://localhost:8080
2. Click **"Sign Up"**
3. Create an account with any email
4. Use the email inbox at http://localhost:54324 to verify your email (optional for local)

### Creating an Admin Account
To make a user an admin:
1. Open Supabase Studio: http://localhost:54323
2. Go to **Table Editor** → **user_roles**
3. Click **"Insert row"**
4. Set:
   - `user_id`: Copy from the `auth.users` table
   - `role`: Select `admin`
5. Click **"Save"**

Now that user has full admin access!

### Managing Data
Access Supabase Studio (http://localhost:54323) to:
- View and edit database tables
- Run SQL queries
- Manage users
- View storage files
- Check logs

---

## 🔧 Common Commands

### Starting/Stopping Supabase
```bash
# Start Supabase
npx supabase start

# Stop Supabase (keeps data)
npx supabase stop

# Reset database (WARNING: deletes all data)
npx supabase db reset

# View status
npx supabase status

# View logs
npx supabase logs
```

### Application Commands
```bash
# Start development server
npm run dev

# Build for production
npm run build

# Preview production build
npm run preview

# Run linter
npm run lint
```

---

## 🛠 Troubleshooting

### "Docker not found"
**Solution:** Install [Docker Desktop](https://www.docker.com/products/docker-desktop) and make sure it's running.

### "Port 54321 already in use"
**Solution:** Another instance of Supabase is running.
```bash
npx supabase stop
# Wait a few seconds, then:
npx supabase start
```

### "Containers won't start"
**Solution:** Clean up Docker and restart.
```bash
npx supabase stop --no-backup
docker system prune -a
npx supabase start
```

### "Tables not found" or "Relation does not exist"
**Solution:** You need to run the database setup SQL.
1. Open http://localhost:54323
2. Go to SQL Editor
3. Run the `LOCAL_SETUP_COMPLETE.sql` file

### "Can't connect to database"
**Solution:** Make sure Supabase is running.
```bash
npx supabase status
# If not running:
npx supabase start
```

### "Out of memory"
**Solution:**
- Close other Docker containers
- Increase Docker memory limit in Docker Desktop settings → Resources
- Minimum 4GB recommended, 8GB ideal

### Application won't start
**Solution:** Check your `.env.local` file has the correct values:
```env
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_PUBLISHABLE_KEY=<your-anon-key-from-supabase-start>
```

---

## 🔄 Alternative: Using Migrations (Advanced)

If you're comfortable with migrations, you can use them instead of the SQL file:

```bash
# After starting Supabase, apply all migrations:
npx supabase db reset

# Or apply them one at a time:
npx supabase migration list
npx supabase db push
```

**Note:** The migrations are in the `supabase/migrations/` folder.

---

## 📊 Performance Tips

1. **Use SSD** for Docker volumes (much faster than HDD)
2. **Allocate enough RAM** to Docker (4GB minimum, 8GB recommended)
3. **Use WSL2** on Windows for better Docker performance
4. **Close unnecessary containers** if memory is limited

---

## 🚀 Moving to Production

When ready to deploy to production:

### Option 1: Deploy to Supabase Cloud (Free Tier)
```bash
# Link to your cloud Supabase project
npx supabase link --project-ref <your-project-ref>

# Push your local database schema to cloud
npx supabase db push
```

### Option 2: Deploy to Railway/Render
- Export your database schema
- Create a new PostgreSQL instance
- Run migrations on the new instance
- Update your `.env` with new connection details

See **DEPLOYMENT.md** for complete deployment instructions.

---

## 📝 Summary

**What you have now:**
- ✅ Fully local PostgreSQL database via Docker
- ✅ Complete Supabase stack (Auth, Database, Storage, Functions)
- ✅ Web-based database admin (Supabase Studio)
- ✅ Email testing interface (Inbucket)
- ✅ No cloud dependencies
- ✅ No monthly costs
- ✅ Full privacy and control

**Key URLs:**
- App: http://localhost:8080
- Database Admin: http://localhost:54323
- Email Testing: http://localhost:54324

**Need help?** Check the troubleshooting section above or see the main [README.md](./README.md) for more information.

