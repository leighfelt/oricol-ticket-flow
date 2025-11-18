#!/bin/bash

# Oricol Helpdesk - Quick Local Start Script
# This script helps you get the app running locally quickly

set -e

echo "🚀 Starting Oricol Helpdesk Locally"
echo "===================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed!"
    echo "Please install Node.js from: https://nodejs.org/"
    exit 1
fi

echo "✅ Node.js is installed ($(node --version))"

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "❌ npm is not installed!"
    echo "Please install npm from: https://nodejs.org/"
    exit 1
fi

echo "✅ npm is installed ($(npm --version))"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed!"
    echo "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop"
    exit 1
fi

echo "✅ Docker is installed ($(docker --version))"

# Check if Docker is running
if ! docker info &> /dev/null; then
    echo "❌ Docker is not running!"
    echo "Please start Docker Desktop and try again."
    exit 1
fi

echo "✅ Docker is running"
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "📦 Installing dependencies..."
    npm install
    echo ""
fi

# Check if Supabase is already running
echo "🔍 Checking if Supabase is already running..."
if npx supabase status &> /dev/null; then
    echo "✅ Supabase is already running!"
    echo ""
else
    echo "🚀 Starting local Supabase..."
    echo "   This may take 1-2 minutes on first run..."
    echo ""
    npx supabase start
    echo ""
    echo "✅ Supabase is now running!"
    echo ""
fi

# Display useful information
echo "📝 Your local environment is ready!"
echo ""
echo "🌐 Services:"
echo "   • Application:     http://localhost:8080"
echo "   • Supabase Studio: http://localhost:54323"
echo "   • Email Testing:   http://localhost:54324"
echo ""

# Check if .env file exists and is configured
if [ -f ".env" ]; then
    if grep -q "localhost:54321" .env; then
        echo "✅ Environment configured for local development"
    else
        echo "⚠️  Note: .env file exists but may not be configured for local development"
        echo "   Expected: VITE_SUPABASE_URL=http://localhost:54321"
    fi
else
    echo "⚠️  Warning: No .env file found. The default configuration should work."
fi

echo ""
echo "🎯 First time setup:"
echo "   1. The app will open in your browser"
echo "   2. Sign up with: craig@zerobitone.co.za or admin@oricol.co.za"
echo "   3. You'll automatically get admin access!"
echo ""
echo "🔧 Useful commands:"
echo "   • Stop Supabase:  npm run supabase:stop"
echo "   • Reset database: npm run supabase:reset"
echo "   • View logs:      npx supabase logs"
echo ""
echo "Starting the application..."
echo ""

# Start the application
npm run dev
