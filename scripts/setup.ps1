# LiteLLM Proxy Setup Script for Windows PowerShell
# This script helps you set up LiteLLM proxy with Docker and PostgreSQL

param(
    [switch]$SkipApiKeys
)

Write-Host "🚀 LiteLLM Proxy Docker Setup (PostgreSQL)" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Check if Docker is installed
try {
    docker --version | Out-Null
    Write-Host "✅ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed. Please install Docker Desktop first." -ForegroundColor Red
    exit 1
}

# Check if Docker Compose is available
try {
    docker-compose --version | Out-Null
    $composeCmd = "docker-compose"
    Write-Host "✅ Docker Compose is installed" -ForegroundColor Green
} catch {
    try {
        docker compose version | Out-Null
        $composeCmd = "docker compose"
        Write-Host "✅ Docker Compose (plugin) is available" -ForegroundColor Green
    } catch {
        Write-Host "❌ Docker Compose is not available. Please install Docker Compose." -ForegroundColor Red
        exit 1
    }
}

# Create .env file if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env file from template..." -ForegroundColor Yellow
    Copy-Item "env.example" ".env"
    Write-Host "✅ Environment file created with pre-configured API keys" -ForegroundColor Green
} else {
    Write-Host "✅ .env file already exists" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔑 Configuration Summary:" -ForegroundColor Blue
Write-Host "========================" -ForegroundColor Blue
Write-Host "Master Key: sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)" -ForegroundColor Cyan
Write-Host "Database: PostgreSQL (local container)" -ForegroundColor Cyan
Write-Host "Azure OpenAI: 4 deployments across multiple regions" -ForegroundColor Cyan
Write-Host "Anthropic Claude: All models configured" -ForegroundColor Cyan
Write-Host ""

Write-Host "🐳 Starting Docker containers..." -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue

# Pull the latest images
Write-Host "📥 Pulling Docker images..." -ForegroundColor Yellow
& $composeCmd pull

# Start the services
Write-Host "🚀 Starting services..." -ForegroundColor Yellow
& $composeCmd up -d

# Wait for services to be ready
Write-Host "⏳ Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Check if services are running
$services = & $composeCmd ps
if ($services -match "Up") {
    Write-Host "✅ Services are running!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 Setup Complete!" -ForegroundColor Green
    Write-Host "=================="
    Write-Host ""
    Write-Host "Your LiteLLM proxy is now running at: http://localhost:4000" -ForegroundColor Cyan
    Write-Host "PostgreSQL is running at: postgresql://localhost:5432" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Available Models:" -ForegroundColor Blue
    Write-Host "-------------------"
    Write-Host "Azure OpenAI:" -ForegroundColor Yellow
    Write-Host "  • gpt-4 (load balanced)" -ForegroundColor Gray
    Write-Host "  • gpt-3.5-turbo (load balanced)" -ForegroundColor Gray
    Write-Host "  • gpt-4o" -ForegroundColor Gray
    Write-Host "  • gpt-4o-mini" -ForegroundColor Gray
    Write-Host "  • text-embedding-3-large" -ForegroundColor Gray
    Write-Host "  • text-embedding-3-small" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Anthropic Claude:" -ForegroundColor Yellow
    Write-Host "  • claude-3-haiku" -ForegroundColor Gray
    Write-Host "  • claude-3-sonnet" -ForegroundColor Gray
    Write-Host "  • claude-3-opus" -ForegroundColor Gray
    Write-Host "  • claude-3-5-sonnet" -ForegroundColor Gray
    Write-Host "  • claude-3-7-sonnet" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📋 Quick Test Commands:" -ForegroundColor Blue
    Write-Host "----------------------"
    Write-Host "# Check health:"
    Write-Host "curl -H `"Authorization: Bearer sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)`" http://localhost:4000/health" -ForegroundColor Gray
    Write-Host ""
    Write-Host "# List available models:"
    Write-Host "curl -H `"Authorization: Bearer sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)`" http://localhost:4000/models" -ForegroundColor Gray
    Write-Host ""
    Write-Host "# Test Azure OpenAI GPT-4:"
    Write-Host "curl -X POST 'http://localhost:4000/chat/completions' \\" -ForegroundColor Gray
    Write-Host "  -H 'Content-Type: application/json' \\" -ForegroundColor Gray
    Write-Host "  -H 'Authorization: Bearer sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)' \\" -ForegroundColor Gray
    Write-Host "  -d '{`"model`": `"gpt-4`", `"messages`": [{`"role`": `"user`", `"content`": `"Hello!`"}]}'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "# Test Claude 3.5 Sonnet:"
    Write-Host "curl -X POST 'http://localhost:4000/chat/completions' \\" -ForegroundColor Gray
    Write-Host "  -H 'Content-Type: application/json' \\" -ForegroundColor Gray
    Write-Host "  -H 'Authorization: Bearer sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)' \\" -ForegroundColor Gray
    Write-Host "  -d '{`"model`": `"claude-3-5-sonnet`", `"messages`": [{`"role`": `"user`", `"content`": `"Hello!`"}]}'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "📚 Documentation: https://docs.litellm.ai/" -ForegroundColor Cyan
    Write-Host "🔧 Admin UI: http://localhost:4000/ui" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📝 Next Steps:" -ForegroundColor Blue
    Write-Host "- Create virtual keys for different users/applications"
    Write-Host "- Set up monitoring and logging"
    Write-Host "- Configure rate limits and budgets"
    Write-Host ""
    Write-Host "🔑 Master Key: sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)" -ForegroundColor Yellow
    Write-Host ""
} else {
    Write-Host "❌ Some services failed to start. Check logs with:" -ForegroundColor Red
    Write-Host "$composeCmd logs" -ForegroundColor Gray
} 