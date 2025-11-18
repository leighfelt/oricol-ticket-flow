# Docker Setup Guide - Local Development

This guide shows you how to run the Oricol Helpdesk app using Docker containers for a complete local development environment.

## Quick Start (Recommended - Using Supabase CLI)

This is the easiest method as it uses the official Supabase CLI to manage the backend.

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running
- Node.js 18+ installed
- 4GB+ RAM available

### Steps

1. **Clone and Install**
   ```bash
   git clone https://github.com/craigfelt/oricol-ticket-flow-34e64301.git
   cd oricol-ticket-flow-34e64301
   npm install
   ```

2. **Start Supabase Backend** (runs in Docker via CLI)
   ```bash
   npx supabase start
   ```
   
   This will output your local credentials. Save these!
   ```
   API URL: http://localhost:54321
   DB URL: postgresql://postgres:postgres@localhost:54322/postgres
   Studio URL: http://localhost:54323
   anon key: eyJhbGc...
   service_role key: eyJhbGc...
   ```

3. **Create Environment File**
   ```bash
   cp .env.example .env.local
   ```
   
   Edit `.env.local`:
   ```env
   VITE_SUPABASE_URL=http://localhost:54321
   VITE_SUPABASE_PUBLISHABLE_KEY=<anon-key-from-step-2>
   VITE_SUPABASE_PROJECT_ID=local
   ```

4. **Start Frontend with Docker**
   ```bash
   docker-compose -f docker-compose.simple.yml up -d
   ```

5. **Access the Application**
   - **Application**: http://localhost:8080
   - **Supabase Studio** (Database Admin): http://localhost:54323
   - **Email Testing** (Inbucket): http://localhost:54324

### Managing the Stack

```bash
# View logs
docker-compose -f docker-compose.simple.yml logs -f

# Stop frontend
docker-compose -f docker-compose.simple.yml down

# Stop Supabase backend
npx supabase stop

# Restart everything
npx supabase start
docker-compose -f docker-compose.simple.yml up -d

# Reset database (WARNING: deletes all data)
npx supabase db reset
```

---

## Advanced Setup (Full Docker Stack)

This method runs everything in Docker containers, including the full Supabase stack. Use this if you want complete isolation or can't use Supabase CLI.

### Prerequisites
- Docker Desktop with at least 8GB RAM allocated
- Docker Compose V2

### Steps

1. **Clone the Repository**
   ```bash
   git clone https://github.com/craigfelt/oricol-ticket-flow-34e64301.git
   cd oricol-ticket-flow-34e64301
   ```

2. **Create Environment File**
   ```bash
   cp .env.example .env
   ```
   
   Edit `.env` with these values:
   ```env
   # Database
   POSTGRES_PASSWORD=postgres
   
   # JWT Secret (must be at least 32 characters)
   JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long
   
   # Supabase Keys (generate with: openssl rand -base64 32)
   VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
   SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU
   
   # Frontend
   VITE_SUPABASE_URL=http://localhost:54321
   VITE_SUPABASE_PROJECT_ID=local
   ```

3. **Start All Services**
   ```bash
   docker-compose up -d
   ```
   
   This will start:
   - Frontend application (port 8080)
   - PostgreSQL database (port 54322)
   - Supabase API gateway (port 54321)
   - Supabase Studio (port 54323)
   - Supabase Auth (port 54324)
   - Storage API (port 54326)
   - REST API (port 54327)
   - SMTP server (port 54328, Web UI: 54329)

4. **Apply Database Migrations**
   
   Wait for all containers to be healthy, then:
   ```bash
   # Connect to the database container
   docker exec -it oricol-supabase-db psql -U postgres -d postgres
   
   # Run migrations manually
   \i /docker-entrypoint-initdb.d/20251108052000_bee9ee20-5a81-402a-bdd9-30cce8e8ecb7.sql
   \i /docker-entrypoint-initdb.d/20251109045855_6a7fc76b-c088-4052-a67d-5471bc1cf984.sql
   # ... (continue with other migration files in order)
   
   # Or exit and run migrations from host
   \q
   ```

5. **Access the Application**
   - **Application**: http://localhost:8080
   - **Supabase Studio**: http://localhost:54323
   - **API Gateway**: http://localhost:54321
   - **Email Web UI**: http://localhost:54329

### Managing the Full Stack

```bash
# View all logs
docker-compose logs -f

# View specific service logs
docker-compose logs -f app
docker-compose logs -f supabase-db

# Stop all services
docker-compose down

# Stop and remove volumes (WARNING: deletes all data)
docker-compose down -v

# Restart a specific service
docker-compose restart app

# Rebuild and restart
docker-compose up -d --build

# Check service health
docker-compose ps
```

---

## Production Deployment

### Build Production Image

```bash
# Build the production image
docker build -t oricol-helpdesk:latest --target production .

# Test the production image
docker run -p 8080:8080 \
  -e VITE_SUPABASE_URL=https://your-project.supabase.co \
  -e VITE_SUPABASE_PUBLISHABLE_KEY=your-anon-key \
  oricol-helpdesk:latest
```

### Deploy to Cloud

The Docker image can be deployed to:
- **AWS ECS/Fargate**
- **Google Cloud Run**
- **Azure Container Instances**
- **Digital Ocean App Platform**
- **Any Kubernetes cluster**

Example for Cloud Run:
```bash
# Tag the image
docker tag oricol-helpdesk:latest gcr.io/your-project/oricol-helpdesk:latest

# Push to registry
docker push gcr.io/your-project/oricol-helpdesk:latest

# Deploy
gcloud run deploy oricol-helpdesk \
  --image gcr.io/your-project/oricol-helpdesk:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars VITE_SUPABASE_URL=https://your-project.supabase.co,VITE_SUPABASE_PUBLISHABLE_KEY=your-key
```

---

## Troubleshooting

### Port Already in Use
If you get "port already allocated" errors:
```bash
# Check what's using the port
lsof -i :8080

# Change the port in docker-compose.yml
# Change "8080:8080" to "8081:8080" for a different port
```

### Database Connection Issues
```bash
# Check if database is running
docker-compose ps supabase-db

# Check database logs
docker-compose logs supabase-db

# Connect directly to database
docker exec -it oricol-supabase-db psql -U postgres
```

### Container Won't Start
```bash
# Check logs for errors
docker-compose logs app

# Remove old containers and volumes
docker-compose down -v

# Rebuild from scratch
docker-compose up -d --build --force-recreate
```

### Migrations Not Applied
```bash
# Apply migrations manually
docker exec -it oricol-supabase-db psql -U postgres -d postgres

# Then run each migration file:
\i /docker-entrypoint-initdb.d/[migration-file-name].sql
```

### Reset Everything
```bash
# Stop and remove everything
docker-compose down -v
npx supabase stop --no-backup

# Remove Docker images
docker rmi oricol-ticket-flow-34e64301-app

# Start fresh
npx supabase start
docker-compose -f docker-compose.simple.yml up -d --build
```

---

## Development Workflow

### Hot Reload Development
The simple Docker setup supports hot reload:
```bash
# Start with hot reload
docker-compose -f docker-compose.simple.yml up

# Make changes to src/ files
# Changes will automatically reload in the browser
```

### Running Tests
```bash
# Run tests in container
docker-compose exec app npm test

# Run linter
docker-compose exec app npm run lint
```

### Database Access
```bash
# Access Supabase Studio
open http://localhost:54323

# Or connect with psql
docker exec -it oricol-supabase-db psql -U postgres

# Or use your favorite database client:
# Host: localhost
# Port: 54322
# Database: postgres
# Username: postgres
# Password: postgres
```

---

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_SUPABASE_URL` | Supabase API URL | `http://localhost:54321` |
| `VITE_SUPABASE_PUBLISHABLE_KEY` | Supabase anon key | `eyJhbGc...` |
| `VITE_SUPABASE_PROJECT_ID` | Project ID | `local` |
| `POSTGRES_PASSWORD` | Database password | `postgres` |
| `JWT_SECRET` | JWT signing secret | `super-secret...` |
| `SUPABASE_SERVICE_ROLE_KEY` | Service role key (for storage) | `eyJhbGc...` |

---

## Next Steps

1. **Create Admin Account**: Visit http://localhost:8080 and sign up with `craig@zerobitone.co.za` to get admin access automatically
2. **Explore Supabase Studio**: Visit http://localhost:54323 to manage your database
3. **Test Email**: Check http://localhost:54329 to see test emails
4. **Start Development**: Make changes to files in `src/` and see them update live!

For more help, see:
- [LOCAL_SETUP.md](./LOCAL_SETUP.md) - Local development without Docker
- [DEPLOYMENT.md](./DEPLOYMENT.md) - Cloud deployment options
- [README.md](./README.md) - Complete project documentation
