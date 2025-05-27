#!/bin/bash

# LiteLLM Proxy Setup Script
# This script helps you set up LiteLLM proxy with Docker

set -e

echo "🚀 LiteLLM Proxy Docker Setup"
echo "=============================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from template..."
    cp env.example .env
    
    # Generate random keys
    MASTER_KEY="sk-$(openssl rand -hex 16)"
    SALT_KEY="sk-$(openssl rand -hex 20)"
    DB_PASSWORD="$(openssl rand -base64 16)"
    
    # Update .env with generated values
    sed -i.bak "s/LITELLM_MASTER_KEY=.*/LITELLM_MASTER_KEY=$MASTER_KEY/" .env
    sed -i.bak "s/LITELLM_SALT_KEY=.*/LITELLM_SALT_KEY=$SALT_KEY/" .env
    sed -i.bak "s/POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=$DB_PASSWORD/" .env
    
    # Remove backup file
    rm .env.bak 2>/dev/null || true
    
    echo "✅ Generated secure keys and passwords"
    echo "🔑 Master Key: $MASTER_KEY"
    echo "🔐 Database Password: $DB_PASSWORD"
    echo ""
    echo "⚠️  IMPORTANT: Save these credentials securely!"
    echo "   The master key is needed to access the proxy admin functions."
    echo ""
else
    echo "✅ .env file already exists"
fi

# Ask user about API keys
echo "🔧 API Key Configuration"
echo "========================"
echo "Do you want to configure API keys for LLM providers? (y/n)"
read -r configure_keys

if [ "$configure_keys" = "y" ] || [ "$configure_keys" = "Y" ]; then
    echo ""
    echo "Enter your API keys (press Enter to skip):"
    
    echo -n "OpenAI API Key: "
    read -r openai_key
    if [ -n "$openai_key" ]; then
        if grep -q "OPENAI_API_KEY=" .env; then
            sed -i.bak "s/# OPENAI_API_KEY=.*/OPENAI_API_KEY=$openai_key/" .env
        else
            echo "OPENAI_API_KEY=$openai_key" >> .env
        fi
        echo "✅ OpenAI API key configured"
    fi
    
    echo -n "Anthropic API Key: "
    read -r anthropic_key
    if [ -n "$anthropic_key" ]; then
        if grep -q "ANTHROPIC_API_KEY=" .env; then
            sed -i.bak "s/# ANTHROPIC_API_KEY=.*/ANTHROPIC_API_KEY=$anthropic_key/" .env
        else
            echo "ANTHROPIC_API_KEY=$anthropic_key" >> .env
        fi
        echo "✅ Anthropic API key configured"
    fi
    
    echo -n "Azure OpenAI API Key: "
    read -r azure_key
    if [ -n "$azure_key" ]; then
        if grep -q "AZURE_API_KEY=" .env; then
            sed -i.bak "s/# AZURE_API_KEY=.*/AZURE_API_KEY=$azure_key/" .env
        else
            echo "AZURE_API_KEY=$azure_key" >> .env
        fi
        
        echo -n "Azure OpenAI Endpoint: "
        read -r azure_endpoint
        if [ -n "$azure_endpoint" ]; then
            if grep -q "AZURE_API_BASE=" .env; then
                sed -i.bak "s|# AZURE_API_BASE=.*|AZURE_API_BASE=$azure_endpoint|" .env
            else
                echo "AZURE_API_BASE=$azure_endpoint" >> .env
            fi
        fi
        echo "✅ Azure OpenAI configured"
    fi
    
    # Remove backup file
    rm .env.bak 2>/dev/null || true
fi

echo ""
echo "🐳 Starting Docker containers..."
echo "================================"

# Pull the latest images
echo "📥 Pulling Docker images..."
docker-compose pull

# Start the services
echo "🚀 Starting services..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running!"
    echo ""
    echo "🎉 Setup Complete!"
    echo "=================="
    echo ""
    echo "Your LiteLLM proxy is now running at: http://localhost:4000"
    echo ""
    echo "📋 Quick Test Commands:"
    echo "----------------------"
    echo "# Check health:"
    echo "curl http://localhost:4000/health"
    echo ""
    echo "# List available models:"
    echo "curl http://localhost:4000/models"
    echo ""
    echo "# Make a test request (replace with your master key):"
    MASTER_KEY=$(grep LITELLM_MASTER_KEY .env | cut -d'=' -f2)
    echo "curl -X POST 'http://localhost:4000/chat/completions' \\"
    echo "  -H 'Content-Type: application/json' \\"
    echo "  -H 'Authorization: Bearer $MASTER_KEY' \\"
    echo "  -d '{\"model\": \"gpt-3.5-turbo\", \"messages\": [{\"role\": \"user\", \"content\": \"Hello!\"}]}'"
    echo ""
    echo "📚 Documentation: https://docs.litellm.ai/"
    echo "🔧 Admin UI: http://localhost:4000/ui (if enabled)"
    echo ""
    echo "📝 Next Steps:"
    echo "- Edit config.yaml to add/modify models"
    echo "- Create virtual keys for different users/applications"
    echo "- Set up monitoring and logging"
    echo ""
else
    echo "❌ Some services failed to start. Check logs with:"
    echo "docker-compose logs"
fi 