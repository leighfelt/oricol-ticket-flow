# Quick Local Setup - 5 Minutes

This guide shows you how to run the **entire app locally** on your computer - no cloud services needed.

## Prerequisites

1. **Docker Desktop** - Download and install from [docker.com](https://www.docker.com/products/docker-desktop)
   - Make sure Docker is running (you should see the Docker icon in your system tray)
   
2. **Node.js 18+** - Install from [nodejs.org](https://nodejs.org/) or using [nvm](https://github.com/nvm-sh/nvm)

That's it! Everything else will be installed automatically.

## Setup Steps

### Option A: Automated Setup (Easiest)

```bash
git clone https://github.com/craigfelt/oricol-ticket-flow-34e64301.git
cd oricol-ticket-flow-34e64301
npm install
./start-local.sh
```

That's it! The script will:
- ✅ Check all prerequisites
- ✅ Start Supabase automatically
- ✅ Launch the app
- ✅ Show you all the URLs

### Option B: Manual Setup

### 1. Clone and Install

```bash
git clone https://github.com/craigfelt/oricol-ticket-flow-34e64301.git
cd oricol-ticket-flow-34e64301
npm install
```

### 2. Start Local Supabase

This command starts a complete Supabase instance (PostgreSQL database, Auth, Storage, etc.) in Docker:

```bash
npm run supabase:start
```

**Wait 1-2 minutes** for it to download images and start. You'll see output like this:

```
Started supabase local development setup.

         API URL: http://localhost:54321
     GraphQL URL: http://localhost:54321/graphql/v1
          DB URL: postgresql://postgres:postgres@localhost:54322/postgres
      Studio URL: http://localhost:54323
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

✅ **Your local database is now running!**

### 3. Verify Configuration

The `.env` file is already configured for local development with default keys. If you need to customize it, open `.env` and verify these settings:

```env
VITE_SUPABASE_URL="http://localhost:54321"
VITE_SUPABASE_PUBLISHABLE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"
VITE_SUPABASE_PROJECT_ID="local"
```

These are the default local Supabase keys and work out of the box!

### 4. Start the Application

```bash
npm run dev
```

The app will start at **http://localhost:8080**

## First Time Login

1. Open your browser to **http://localhost:8080**
2. Click **"Sign Up"** 
3. Create an account with email: **craig@zerobitone.co.za** or **admin@oricol.co.za**
   - These emails automatically get admin access!
4. Sign in and start using the app

## Useful Tools

### Supabase Studio (Database Admin)
Open **http://localhost:54323** to:
- View and edit database tables
- Run SQL queries
- Manage users and roles
- View storage files

### Email Testing
Open **http://localhost:54324** to:
- View all emails sent by the app
- Test password resets and email verification

## Daily Usage

When you want to use the app:

```bash
# Check if Supabase is running
npm run supabase:status

# If not running, start it
npm run supabase:start

# Then start the app
npm run dev
```

Or use the combined command:
```bash
npm run local:start
```

## Stopping Everything

```bash
# Stop the frontend (press Ctrl+C in the terminal running npm run dev)

# Stop Supabase (keeps your data)
npm run supabase:stop
```

## Resetting the Database

⚠️ **Warning**: This deletes all data!

```bash
npm run supabase:reset
```

## What's Running Locally?

When you run this setup, you have a complete local environment:

- ✅ **Frontend App** - React app at http://localhost:8080
- ✅ **PostgreSQL Database** - Full database at localhost:54322
- ✅ **Supabase API** - REST API at http://localhost:54321
- ✅ **Authentication** - Complete auth system
- ✅ **Storage** - File storage system
- ✅ **Supabase Studio** - Database admin UI at http://localhost:54323
- ✅ **Email Testing** - Email inbox at http://localhost:54324

All running on your computer, no cloud services needed!

## Troubleshooting

### Docker not installed?
Install Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)

### Docker not running?
Start Docker Desktop and wait for it to be ready (green icon)

### Port already in use?
Another instance might be running:
```bash
npm run supabase:stop
# Wait 10 seconds
npm run supabase:start
```

### Tables not found?
The migrations should apply automatically. If not:
```bash
npm run supabase:reset
```

### Need more help?
See the detailed guide in [LOCAL_SETUP.md](./LOCAL_SETUP.md)

## Next Steps

- Read the full [README.md](./README.md) for all features
- Check [LOCAL_SETUP.md](./LOCAL_SETUP.md) for advanced configuration
- See [DEPLOYMENT.md](./DEPLOYMENT.md) when ready to deploy to production

## Benefits of Local Development

✅ **No cloud costs** - Everything runs on your computer  
✅ **No internet required** - Work offline after initial setup  
✅ **Fast development** - No network latency  
✅ **Full control** - Complete access to database and configuration  
✅ **Privacy** - Your data never leaves your computer  
✅ **Easy testing** - Experiment without affecting production  

---

**That's it!** You now have a fully functional local development environment. Happy coding! 🚀
