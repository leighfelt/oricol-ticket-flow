#!/bin/bash

# Quick switch script for local vs lovable configurations
# Usage: ./switch-config.sh local
#        ./switch-config.sh lovable

set -e

CONFIG=$1

if [ -z "$CONFIG" ]; then
    echo "Usage: ./switch-config.sh [local|lovable]"
    echo ""
    echo "Examples:"
    echo "  ./switch-config.sh local    - Switch to local development config"
    echo "  ./switch-config.sh lovable  - Switch to lovable/cloud config"
    exit 1
fi

case "$CONFIG" in
    local)
        echo "🔄 Switching to LOCAL configuration..."
        cp .env.local .env
        echo "✅ Copied .env.local to .env"
        echo ""
        echo "📝 Next steps:"
        echo "  1. Start Docker services:"
        echo "     docker compose -f docker-compose.yml -f docker-compose.override.local.yml up -d"
        echo ""
        echo "  2. Start dev server:"
        echo "     npm run dev"
        echo ""
        echo "  3. Access at:"
        echo "     - Frontend: http://localhost:5173"
        echo "     - API: http://localhost:8001"
        echo "     - Studio: http://localhost:3001"
        ;;
    
    lovable)
        echo "🔄 Switching to LOVABLE configuration..."
        cp .env.lovable .env
        echo "✅ Copied .env.lovable to .env"
        echo ""
        echo "📝 Next steps:"
        echo "  Option A - Use cloud Supabase (recommended for lovable):"
        echo "     npm run build && npm run preview"
        echo ""
        echo "  Option B - Use self-hosted with Docker:"
        echo "     docker compose -f docker-compose.yml -f docker-compose.override.lovable.yml up -d"
        echo "     npm run build && npm run preview"
        ;;
    
    *)
        echo "❌ Invalid config: $CONFIG"
        echo "Usage: ./switch-config.sh [local|lovable]"
        exit 1
        ;;
esac

echo ""
echo "✅ Configuration switched successfully!"
