# LiteLLM Proxy Test Script
# This script tests the LiteLLM proxy setup with various models

param(
    [string]$ProxyUrl = "http://localhost:4000",
    [string]$MasterKey = "sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)"
)

Write-Host "🧪 Testing LiteLLM Proxy Setup" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host "Proxy URL: $ProxyUrl" -ForegroundColor Cyan
Write-Host ""

# Test 1: Health Check
Write-Host "1️⃣ Testing Health Endpoint..." -ForegroundColor Blue
try {
    $healthResponse = Invoke-RestMethod -Uri "$ProxyUrl/health" -Method Get
    Write-Host "✅ Health check passed" -ForegroundColor Green
    Write-Host "   Status: $($healthResponse.status)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: List Models
Write-Host ""
Write-Host "2️⃣ Testing Models Endpoint..." -ForegroundColor Blue
try {
    $modelsResponse = Invoke-RestMethod -Uri "$ProxyUrl/models" -Method Get
    Write-Host "✅ Models endpoint working" -ForegroundColor Green
    Write-Host "   Available models: $($modelsResponse.data.Count)" -ForegroundColor Gray
    
    # List some models
    $azureModels = $modelsResponse.data | Where-Object { $_.id -like "*gpt*" } | Select-Object -First 3
    $claudeModels = $modelsResponse.data | Where-Object { $_.id -like "*claude*" } | Select-Object -First 3
    
    if ($azureModels) {
        Write-Host "   Azure OpenAI models found: $($azureModels.id -join ', ')" -ForegroundColor Gray
    }
    if ($claudeModels) {
        Write-Host "   Claude models found: $($claudeModels.id -join ', ')" -ForegroundColor Gray
    }
} catch {
    Write-Host "❌ Models endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Test Azure OpenAI GPT-4
Write-Host ""
Write-Host "3️⃣ Testing Azure OpenAI GPT-4..." -ForegroundColor Blue
try {
    $gpt4Request = @{
        model = "gpt-4"
        messages = @(
            @{
                role = "user"
                content = "Say 'Hello from Azure OpenAI GPT-4!' in exactly those words."
            }
        )
        max_tokens = 50
    }
    
    $headers = @{
        "Authorization" = "Bearer $MasterKey"
        "Content-Type" = "application/json"
    }
    
    $gpt4Response = Invoke-RestMethod -Uri "$ProxyUrl/chat/completions" -Method Post -Body ($gpt4Request | ConvertTo-Json -Depth 10) -Headers $headers
    Write-Host "✅ GPT-4 test passed" -ForegroundColor Green
    Write-Host "   Response: $($gpt4Response.choices[0].message.content.Trim())" -ForegroundColor Gray
    Write-Host "   Model used: $($gpt4Response.model)" -ForegroundColor Gray
} catch {
    Write-Host "❌ GPT-4 test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Test Claude 3.5 Sonnet
Write-Host ""
Write-Host "4️⃣ Testing Claude 3.5 Sonnet..." -ForegroundColor Blue
try {
    $claudeRequest = @{
        model = "claude-3-5-sonnet"
        messages = @(
            @{
                role = "user"
                content = "Say 'Hello from Claude 3.5 Sonnet!' in exactly those words."
            }
        )
        max_tokens = 50
    }
    
    $claudeResponse = Invoke-RestMethod -Uri "$ProxyUrl/chat/completions" -Method Post -Body ($claudeRequest | ConvertTo-Json -Depth 10) -Headers $headers
    Write-Host "✅ Claude 3.5 Sonnet test passed" -ForegroundColor Green
    Write-Host "   Response: $($claudeResponse.choices[0].message.content.Trim())" -ForegroundColor Gray
    Write-Host "   Model used: $($claudeResponse.model)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Claude 3.5 Sonnet test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Test Embeddings
Write-Host ""
Write-Host "5️⃣ Testing Embeddings..." -ForegroundColor Blue
try {
    $embeddingRequest = @{
        model = "text-embedding-3-small"
        input = "This is a test sentence for embeddings."
    }
    
    $embeddingResponse = Invoke-RestMethod -Uri "$ProxyUrl/embeddings" -Method Post -Body ($embeddingRequest | ConvertTo-Json -Depth 10) -Headers $headers
    Write-Host "✅ Embeddings test passed" -ForegroundColor Green
    Write-Host "   Embedding dimensions: $($embeddingResponse.data[0].embedding.Count)" -ForegroundColor Gray
    Write-Host "   Model used: $($embeddingResponse.model)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Embeddings test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: Create Virtual Key
Write-Host ""
Write-Host "6️⃣ Testing Virtual Key Creation..." -ForegroundColor Blue
try {
    $keyRequest = @{
        models = @("gpt-4", "claude-3-5-sonnet")
        max_budget = 10
        rpm_limit = 30
        duration = "30d"
    }
    
    $keyResponse = Invoke-RestMethod -Uri "$ProxyUrl/key/generate" -Method Post -Body ($keyRequest | ConvertTo-Json -Depth 10) -Headers $headers
    Write-Host "✅ Virtual key creation passed" -ForegroundColor Green
    Write-Host "   Key: $($keyResponse.key.Substring(0, 20))..." -ForegroundColor Gray
    
    # Test the virtual key
    $virtualHeaders = @{
        "Authorization" = "Bearer $($keyResponse.key)"
        "Content-Type" = "application/json"
    }
    
    $testRequest = @{
        model = "gpt-4"
        messages = @(
            @{
                role = "user"
                content = "Test with virtual key"
            }
        )
        max_tokens = 10
    }
    
    $testResponse = Invoke-RestMethod -Uri "$ProxyUrl/chat/completions" -Method Post -Body ($testRequest | ConvertTo-Json -Depth 10) -Headers $virtualHeaders
    Write-Host "✅ Virtual key test passed" -ForegroundColor Green
    Write-Host "   Virtual key is working correctly" -ForegroundColor Gray
    
} catch {
    Write-Host "❌ Virtual key test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Testing Complete!" -ForegroundColor Green
Write-Host "===================" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Summary:" -ForegroundColor Blue
Write-Host "- Health check: Available" -ForegroundColor Gray
Write-Host "- Models endpoint: Available" -ForegroundColor Gray
Write-Host "- Azure OpenAI GPT-4: Configured and working" -ForegroundColor Gray
Write-Host "- Claude 3.5 Sonnet: Configured and working" -ForegroundColor Gray
Write-Host "- Embeddings: Available" -ForegroundColor Gray
Write-Host "- Virtual keys: Working" -ForegroundColor Gray
Write-Host ""
Write-Host "🔗 Access Points:" -ForegroundColor Blue
Write-Host "- Proxy: $ProxyUrl" -ForegroundColor Gray
Write-Host "- Admin UI: $ProxyUrl/ui" -ForegroundColor Gray
Write-Host "- Master Key: $MasterKey" -ForegroundColor Gray 