# Preserving Lovable Deployment & Running Local Copy

This guide explains how to preserve the current lovable deployment while running a local development copy side-by-side.

## Overview

You can run **both** the lovable deployment and a local development copy simultaneously without conflicts. This is achieved through:

1. **Branch/Tag Pinning**: Lovable runs from a specific branch/tag that doesn't change
2. **Separate Configuration**: Different environment files for different credentials
3. **Different Ports/Volumes**: Docker override files prevent port and volume conflicts

## Quick Start

### For Local Development

```bash
# 1. Copy the local environment file
cp .env.local .env

# 2. Start local Docker services
docker compose -f docker-compose.yml -f docker-compose.override.local.yml up -d

# 3. Start the development server
npm run dev

# 4. Access the app at:
# - Frontend: http://localhost:5173 (Vite dev server)
# - API Gateway: http://localhost:8001
# - Studio: http://localhost:3001
# - Mail UI: http://localhost:9001
```

### For Lovable/Cloud Deployment

```bash
# 1. Copy the lovable environment file
cp .env.lovable .env

# 2. Start lovable Docker services (if self-hosted)
docker compose -f docker-compose.yml -f docker-compose.override.lovable.yml up -d

# 3. Build and serve production build
npm run build
npm run preview
```

## Detailed Setup

### Step 1: Preserve the Current Lovable Deployment

The current lovable deployment is pinned to commit `808152c`. To ensure it continues running unchanged:

#### Option A: Create a Preserved Branch (Recommended)

```bash
# Fetch the latest changes
git fetch origin

# Create a branch at the lovable commit
git checkout -b lovable-preserve 808152c

# Push to remote (requires permissions)
git push origin lovable-preserve
```

Then configure lovable to deploy from the `lovable-preserve` branch instead of `main`.

#### Option B: Create a Tag

```bash
# Create a tag at the lovable commit
git tag -a lovable-v1 808152c -m "Lock current lovable deployment"

# Push to remote (requires permissions)
git push origin lovable-v1
```

Then configure lovable to deploy from the `lovable-v1` tag.

### Step 2: Understand the Configuration Files

#### Docker Compose Override Files

**`docker-compose.override.local.yml`**
- Changes ports so local services don't conflict with cloud/other instances
- Uses separate volume names (`postgres-data-local`, `storage-data-local`)
- Local services run on different ports:
  - PostgreSQL: 5433 (instead of 5432)
  - Studio: 3001 (instead of 3000)
  - Kong API: 8001 (instead of 8000)
  - Mail UI: 9001 (instead of 9000)

**`docker-compose.override.lovable.yml`**
- Uses separate volume names for lovable deployment
- Keeps standard ports (5432, 3000, 8000, etc.)
- Used when running lovable deployment on same host or for standardization

#### Environment Files

**`.env.local`** - Local Development
- Connects to local Docker services (port 8001)
- Uses development credentials
- Safe to use for testing

**`.env.lovable`** - Lovable/Cloud Deployment
- Contains the actual cloud Supabase credentials
- **DO NOT COMMIT** - already in .gitignore
- Used for lovable deployment or to connect to cloud Supabase

### Step 3: Running Both Instances

#### Local Development Instance

```bash
# Copy local config
cp .env.local .env

# Start local backend services
docker compose -f docker-compose.yml -f docker-compose.override.local.yml up -d

# Wait for services to be healthy
docker compose -f docker-compose.yml -f docker-compose.override.local.yml ps

# Start frontend dev server
npm run dev
```

Your local app will be available at:
- **Frontend**: http://localhost:5173
- **API**: http://localhost:8001
- **Studio**: http://localhost:3001
- **Mail**: http://localhost:9001

#### Lovable Instance (Cloud)

The lovable instance uses cloud Supabase, so you typically don't need Docker for it. Just:

```bash
# Copy lovable config
cp .env.lovable .env

# Start the app (connects to cloud Supabase)
npm run dev
# or for production:
npm run build && npm run preview
```

#### Lovable Instance (Self-Hosted on Same Machine)

If you want to run a lovable-like instance locally with Docker:

```bash
# Copy lovable config
cp .env.lovable .env

# Start backend services with lovable override
docker compose -f docker-compose.yml -f docker-compose.override.lovable.yml up -d

# Start the app
npm run build && npm run preview
```

## Stopping Instances

### Stop Local Instance

```bash
# Stop and remove containers (keeps volumes)
docker compose -f docker-compose.yml -f docker-compose.override.local.yml down

# Stop and remove everything including volumes
docker compose -f docker-compose.yml -f docker-compose.override.local.yml down -v
```

### Stop Lovable Instance

```bash
# Stop and remove containers
docker compose -f docker-compose.yml -f docker-compose.override.lovable.yml down

# Stop and remove everything including volumes
docker compose -f docker-compose.yml -f docker-compose.override.lovable.yml down -v
```

## Database Considerations

### Separate Databases (Recommended)

By default, local and lovable instances use **separate databases**:
- Local: Uses local Docker PostgreSQL with volume `postgres-data-local`
- Lovable: Uses cloud Supabase or separate volume `postgres-data-lovable`

This isolation prevents:
- Local changes affecting production data
- Migration conflicts
- Data corruption

### Shared Database (Advanced)

If you need both instances to share data, point both to the same external database:

1. Update both `.env.local` and `.env.lovable` to use the same external DB connection
2. Be careful with migrations - they affect both instances
3. Consider using database backups before testing

## Migrations

Database migrations are stored in `supabase/migrations/`. Apply them carefully:

### For Local Database

```bash
# Make sure you're using local config
cp .env.local .env

# Apply migrations through Docker
docker compose -f docker-compose.yml -f docker-compose.override.local.yml restart postgres
```

Migrations in `supabase/migrations/` are automatically applied on PostgreSQL startup.

### For Lovable Database

If lovable uses cloud Supabase, apply migrations through the Supabase Dashboard or CLI.

## Reverting Lovable to Old Version

If you need to revert the lovable deployment to the preserved version:

### Option 1: Deploy from Preserved Branch/Tag

Configure lovable to deploy from:
- Branch: `lovable-preserve`
- Tag: `lovable-v1`

### Option 2: Merge Preserved Version to Main

```bash
# Switch to main branch
git checkout main

# Merge the preserved branch
git merge --no-ff lovable-preserve

# Push to GitHub
git push origin main
```

### Option 3: Reset Main to Preserved Version (Destructive)

⚠️ **Warning**: This rewrites history!

```bash
# Switch to main
git checkout main

# Reset to preserved version
git reset --hard lovable-preserve

# Force push (requires force push permissions)
git push --force origin main
```

## Development Workflow

### Typical Workflow

1. **Keep lovable running** on the `lovable-preserve` branch
2. **Develop locally** on `main` or feature branches
3. **Test changes** locally before pushing
4. **When ready**, update lovable to point to a new stable branch/tag

### Continuous Development

```bash
# Terminal 1: Keep local services running
docker compose -f docker-compose.yml -f docker-compose.override.local.yml up

# Terminal 2: Run dev server
npm run dev

# Terminal 3: Make changes
git checkout -b feature/new-feature
# ... make changes ...
# Local dev server auto-reloads
```

## Troubleshooting

### Port Conflicts

If you get "port already in use" errors:

```bash
# Check what's using the port
lsof -i :8001  # or whatever port

# Make sure you're using the correct override file
docker compose -f docker-compose.yml -f docker-compose.override.local.yml down
```

### Wrong Configuration

If the app connects to the wrong backend:

```bash
# Verify which .env is active
cat .env

# Ensure it matches what you want
cp .env.local .env  # for local
# or
cp .env.lovable .env  # for lovable
```

### Services Not Starting

```bash
# Check service logs
docker compose -f docker-compose.yml -f docker-compose.override.local.yml logs postgres
docker compose -f docker-compose.yml -f docker-compose.override.local.yml logs kong

# Check service health
docker compose -f docker-compose.yml -f docker-compose.override.local.yml ps
```

## Best Practices

1. ✅ **Never commit** `.env`, `.env.local`, or `.env.lovable` (already in .gitignore)
2. ✅ **Document** which branch/tag lovable deploys from in your README
3. ✅ **Tag** stable versions before deploying to lovable
4. ✅ **Test** migrations on local before applying to lovable
5. ✅ **Backup** production database regularly
6. ✅ **Use different secrets** for local vs lovable
7. ✅ **Keep local and lovable configs** in sync (except for secrets/URLs)

## Summary

- **Lovable**: Deploys from `lovable-preserve` branch/tag, uses cloud Supabase
- **Local**: Develops on `main`, uses local Docker services on alternate ports
- **Configuration**: Managed through `.env.local` and `.env.lovable` files
- **Isolation**: Separate ports, volumes, and databases prevent conflicts
- **Workflow**: Develop locally, test thoroughly, then update lovable deployment
