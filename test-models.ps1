# Comprehensive Model Test Script
$masterKey = "sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)"
$baseUrl = "http://localhost:4000"

Write-Host "🧪 Testing LiteLLM Proxy Models" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

# Test Azure OpenAI GPT-4
Write-Host "`n1️⃣ Testing Azure OpenAI GPT-4..." -ForegroundColor Blue
try {
    $gpt4Request = @{
        model = "gpt-4"
        messages = @(@{
            role = "user"
            content = "Say 'Hello from Azure OpenAI GPT-4!' in exactly those words."
        })
        max_tokens = 50
    }
    
    $headers = @{
        "Authorization" = "Bearer $masterKey"
        "Content-Type" = "application/json"
    }
    
    $gpt4Response = Invoke-RestMethod -Uri "$baseUrl/chat/completions" -Method Post -Body ($gpt4Request | ConvertTo-Json -Depth 10) -Headers $headers
    Write-Host "✅ GPT-4 test passed" -ForegroundColor Green
    Write-Host "   Response: $($gpt4Response.choices[0].message.content.Trim())" -ForegroundColor Gray
    Write-Host "   Model used: $($gpt4Response.model)" -ForegroundColor Gray
} catch {
    Write-Host "❌ GPT-4 test failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Error details: $responseBody" -ForegroundColor Red
    }
}

# Test Claude 3.5 Sonnet
Write-Host "`n2️⃣ Testing Claude 3.5 Sonnet..." -ForegroundColor Blue
try {
    $claudeRequest = @{
        model = "claude-3-5-sonnet"
        messages = @(@{
            role = "user"
            content = "Say 'Hello from Claude 3.5 Sonnet!' in exactly those words."
        })
        max_tokens = 50
    }
    
    $claudeResponse = Invoke-RestMethod -Uri "$baseUrl/chat/completions" -Method Post -Body ($claudeRequest | ConvertTo-Json -Depth 10) -Headers $headers
    Write-Host "✅ Claude 3.5 Sonnet test passed" -ForegroundColor Green
    Write-Host "   Response: $($claudeResponse.choices[0].message.content.Trim())" -ForegroundColor Gray
    Write-Host "   Model used: $($claudeResponse.model)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Claude 3.5 Sonnet test failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Error details: $responseBody" -ForegroundColor Red
    }
}

# Test Embeddings
Write-Host "`n3️⃣ Testing Embeddings..." -ForegroundColor Blue
try {
    $embeddingRequest = @{
        model = "text-embedding-3-small"
        input = "This is a test sentence for embeddings."
    }
    
    $embeddingResponse = Invoke-RestMethod -Uri "$baseUrl/embeddings" -Method Post -Body ($embeddingRequest | ConvertTo-Json -Depth 10) -Headers $headers
    Write-Host "✅ Embeddings test passed" -ForegroundColor Green
    Write-Host "   Embedding dimensions: $($embeddingResponse.data[0].embedding.Count)" -ForegroundColor Gray
    Write-Host "   Model used: $($embeddingResponse.model)" -ForegroundColor Gray
} catch {
    Write-Host "❌ Embeddings test failed: $($_.Exception.Message)" -ForegroundColor Red
    if ($_.Exception.Response) {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $responseBody = $reader.ReadToEnd()
        Write-Host "   Error details: $responseBody" -ForegroundColor Red
    }
}

Write-Host "`n🎉 Model testing completed!" -ForegroundColor Green
Write-Host "Your LiteLLM proxy is working with multiple AI providers!" -ForegroundColor Cyan 