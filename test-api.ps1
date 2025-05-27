# Simple API Test Script
$masterKey = "sk-?/)*oa#ixm4e(WJXbcxkWrC@2#b!>o>)"
$baseUrl = "http://localhost:4000"

Write-Host "🧪 Testing LiteLLM Proxy API" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green

# Test 1: Health Check
Write-Host "`n1️⃣ Testing Health Endpoint..." -ForegroundColor Blue
try {
    $healthResponse = Invoke-RestMethod -Uri "$baseUrl/health" -Method Get -Headers @{"Authorization" = "Bearer $masterKey"}
    Write-Host "✅ Health check passed" -ForegroundColor Green
} catch {
    Write-Host "❌ Health check failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Test 2: List Models
Write-Host "`n2️⃣ Testing Models Endpoint..." -ForegroundColor Blue
try {
    $modelsResponse = Invoke-RestMethod -Uri "$baseUrl/models" -Method Get -Headers @{"Authorization" = "Bearer $masterKey"}
    Write-Host "✅ Models endpoint working" -ForegroundColor Green
    Write-Host "   Available models: $($modelsResponse.data.Count)" -ForegroundColor Gray
    
    # Show some model names
    $modelNames = $modelsResponse.data | Select-Object -First 5 | ForEach-Object { $_.id }
    Write-Host "   Sample models: $($modelNames -join ', ')" -ForegroundColor Gray
} catch {
    Write-Host "❌ Models endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Basic tests completed!" -ForegroundColor Green
Write-Host "Your LiteLLM proxy is running at: $baseUrl" -ForegroundColor Cyan
Write-Host "Master Key: $masterKey" -ForegroundColor Yellow 