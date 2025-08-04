#!/bin/bash

# StealthList Local Development Setup Script
# This script helps new users set up their local and production environments

echo "🚀 StealthList Environment Setup"
echo "================================"
echo ""

# Check if .env.local already exists
if [ -f .env.local ]; then
    echo "⚠️  .env.local already exists!"
    read -p "Do you want to overwrite it? (y/N): " overwrite_local
    if [[ ! $overwrite_local =~ ^[Yy]$ ]]; then
        echo "⏭️  Skipping .env.local creation"
        local_created=false
    else
        local_created=true
    fi
else
    local_created=true
fi

# Check if .env.prod already exists
if [ -f .env.prod ]; then
    echo "⚠️  .env.prod already exists!"
    read -p "Do you want to overwrite it? (y/N): " overwrite_prod
    if [[ ! $overwrite_prod =~ ^[Yy]$ ]]; then
        echo "⏭️  Skipping .env.prod creation"
        prod_created=false
    else
        prod_created=true
    fi
else
    prod_created=true
fi

# Create .env.local
if [ "$local_created" = true ]; then
    if [ -f .env.example.local ]; then
        cp .env.example.local .env.local
        echo "✅ Copied .env.example.local to .env.local"
    else
        echo "❌ Error: .env.example.local not found!"
        exit 1
    fi
fi

# Create .env.prod
if [ "$prod_created" = true ]; then
    if [ -f .env.example.prod ]; then
        cp .env.example.prod .env.prod
        echo "✅ Copied .env.example.prod to .env.prod"
    else
        echo "❌ Error: .env.example.prod not found!"
        exit 1
    fi
fi

echo ""
echo "📝 Next Steps:"

step_number=1

if [ "$local_created" = true ]; then
    echo "$step_number. Edit .env.local with your local database credentials"
    step_number=$((step_number + 1))
fi

if [ "$prod_created" = true ]; then
    echo "$step_number. Edit .env.prod with your production database credentials"
    step_number=$((step_number + 1))
fi

echo "$step_number. Test your local setup:"
echo "   bun run db:stats"
echo ""
echo "Setup Complete! 🥷" 