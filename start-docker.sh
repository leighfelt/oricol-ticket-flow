#!/bin/bash

# Oricol Helpdesk - Quick Start Script for Docker Setup
# This script helps you get the app running locally with Docker

set -e

echo "🚀 Oricol Helpdesk - Docker Quick Start"
echo "========================================"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running!"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo "✅ Docker is installed and running"
echo ""

# Ask which setup method to use
echo "Choose your setup method:"
echo "1. Simple Setup (Recommended) - Uses Supabase CLI + Docker for frontend"
echo "2. Full Docker Stack - Everything in Docker containers"
echo ""
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" = "1" ]; then
    echo ""
    echo "📦 Setting up Simple Docker Setup..."
    echo ""
    
    # Check if npm is installed
    if ! command -v npm &> /dev/null; then
        echo "❌ npm is not installed!"
        echo "Please install Node.js from: https://nodejs.org/"
        exit 1
    fi
    
    echo "Installing dependencies..."
    npm install
    
    echo ""
    echo "Starting Supabase backend..."
    npx supabase start
    
    echo ""
    echo "⚠️  IMPORTANT: Copy the 'anon key' from above"
    echo ""
    read -p "Press Enter when you're ready to continue..."
    
    # Create .env.local if it doesn't exist
    if [ ! -f .env.local ]; then
        echo ""
        read -p "Enter your Supabase anon key: " anon_key
        cat > .env.local << EOF
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_PUBLISHABLE_KEY=$anon_key
VITE_SUPABASE_PROJECT_ID=local
EOF
        echo "✅ Created .env.local file"
    else
        echo "✅ .env.local already exists"
    fi
    
    echo ""
    echo "Starting frontend with Docker..."
    docker-compose -f docker-compose.simple.yml up -d
    
    echo ""
    echo "✅ Setup complete!"
    echo ""
    echo "🌐 Access your application:"
    echo "   Application:      http://localhost:8080"
    echo "   Supabase Studio:  http://localhost:54323"
    echo "   Email Testing:    http://localhost:54324"
    echo ""
    echo "👤 First time setup:"
    echo "   1. Visit http://localhost:8080"
    echo "   2. Sign up with: craig@zerobitone.co.za"
    echo "   3. You'll automatically get admin access!"
    echo ""
    echo "📝 To view logs:"
    echo "   docker-compose -f docker-compose.simple.yml logs -f"
    echo ""
    echo "🛑 To stop:"
    echo "   docker-compose -f docker-compose.simple.yml down"
    echo "   npx supabase stop"
    echo ""
    
elif [ "$choice" = "2" ]; then
    echo ""
    echo "📦 Setting up Full Docker Stack..."
    echo ""
    
    # Create .env if it doesn't exist
    if [ ! -f .env ]; then
        echo "Creating .env file with default values..."
        cat > .env << 'EOF'
# Database
POSTGRES_PASSWORD=postgres

# JWT Secret (must be at least 32 characters)
JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long

# Supabase Keys
VITE_SUPABASE_PUBLISHABLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4MzgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU

# Frontend
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_PROJECT_ID=local
EOF
        echo "✅ Created .env file"
    else
        echo "✅ .env already exists"
    fi
    
    echo ""
    echo "Starting all services..."
    docker-compose up -d
    
    echo ""
    echo "⏳ Waiting for services to be ready..."
    sleep 10
    
    echo ""
    echo "✅ Setup complete!"
    echo ""
    echo "🌐 Access your application:"
    echo "   Application:      http://localhost:8080"
    echo "   Supabase Studio:  http://localhost:54323"
    echo "   API Gateway:      http://localhost:54321"
    echo "   Email Web UI:     http://localhost:54329"
    echo ""
    echo "👤 First time setup:"
    echo "   1. Visit http://localhost:8080"
    echo "   2. Sign up with: craig@zerobitone.co.za"
    echo "   3. You'll automatically get admin access!"
    echo ""
    echo "📝 To view logs:"
    echo "   docker-compose logs -f"
    echo ""
    echo "🛑 To stop:"
    echo "   docker-compose down"
    echo ""
    
else
    echo "Invalid choice. Please run the script again and choose 1 or 2."
    exit 1
fi

echo "📚 For more information, see DOCKER_SETUP.md"
