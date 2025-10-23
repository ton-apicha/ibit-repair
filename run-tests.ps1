# 🧪 Test Execution Script สำหรับ iBit Repair System

Write-Host "🚀 Starting iBit Repair System Test Suite" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Yellow

# 1. ตรวจสอบ Services
Write-Host "`n📊 Checking Services..." -ForegroundColor Cyan

# ตรวจสอบ Backend
$backendPort = netstat -ano | findstr :4000
if ($backendPort) {
    Write-Host "✅ Backend Server: Running on port 4000" -ForegroundColor Green
} else {
    Write-Host "❌ Backend Server: Not running" -ForegroundColor Red
    Write-Host "Starting Backend Server..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-Command", "cd 'D:\VSCode\ibit-repair\backend'; npm run dev" -WindowStyle Minimized
    Start-Sleep -Seconds 5
}

# ตรวจสอบ Frontend
$frontendPort = netstat -ano | findstr :3000
if ($frontendPort) {
    Write-Host "✅ Frontend Server: Running on port 3000" -ForegroundColor Green
} else {
    Write-Host "❌ Frontend Server: Not running" -ForegroundColor Red
    Write-Host "Starting Frontend Server..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-Command", "cd 'D:\VSCode\ibit-repair\frontend'; npm run dev" -WindowStyle Minimized
    Start-Sleep -Seconds 5
}

# 2. ทดสอบ Backend Health
Write-Host "`n🔍 Testing Backend Health..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:4000/health" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Backend Health: OK" -ForegroundColor Green
        $healthData = $response.Content | ConvertFrom-Json
        Write-Host "   Status: $($healthData.status)" -ForegroundColor White
        Write-Host "   Message: $($healthData.message)" -ForegroundColor White
    } else {
        Write-Host "❌ Backend Health: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Backend Health: Connection failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 3. ทดสอบ Frontend
Write-Host "`n🔍 Testing Frontend..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -UseBasicParsing -TimeoutSec 5
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Frontend: Accessible" -ForegroundColor Green
    } else {
        Write-Host "❌ Frontend: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Frontend: Connection failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 4. ทดสอบ Login API
Write-Host "`n🔐 Testing Login API..." -ForegroundColor Cyan

# ทดสอบ Admin Login
try {
    $loginData = @{
        username = "admin"
        password = "admin123"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:4000/api/auth/login" -Method POST -Body $loginData -ContentType "application/json" -UseBasicParsing -TimeoutSec 5
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Admin Login: Success" -ForegroundColor Green
        $loginResult = $response.Content | ConvertFrom-Json
        $adminToken = $loginResult.token
        Write-Host "   Token: $($adminToken.Substring(0, 20))..." -ForegroundColor White
    } else {
        Write-Host "❌ Admin Login: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Admin Login: Connection failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# ทดสอบ Technician Login
try {
    $loginData = @{
        username = "technician1"
        password = "tech123"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:4000/api/auth/login" -Method POST -Body $loginData -ContentType "application/json" -UseBasicParsing -TimeoutSec 5
    
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Technician Login: Success" -ForegroundColor Green
        $loginResult = $response.Content | ConvertFrom-Json
        $techToken = $loginResult.token
        Write-Host "   Token: $($techToken.Substring(0, 20))..." -ForegroundColor White
    } else {
        Write-Host "❌ Technician Login: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Technician Login: Connection failed" -ForegroundColor Red
    Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
}

# 5. ทดสอบ Invalid Login
try {
    $loginData = @{
        username = "invaliduser"
        password = "invalidpass"
    } | ConvertTo-Json

    $response = Invoke-WebRequest -Uri "http://localhost:4000/api/auth/login" -Method POST -Body $loginData -ContentType "application/json" -UseBasicParsing -TimeoutSec 5
    
    Write-Host "❌ Invalid Login: Should have failed but succeeded" -ForegroundColor Red
} catch {
    if ($_.Exception.Response.StatusCode -eq 401) {
        Write-Host "✅ Invalid Login: Correctly rejected" -ForegroundColor Green
    } else {
        Write-Host "❌ Invalid Login: Unexpected error (Status: $($_.Exception.Response.StatusCode))" -ForegroundColor Red
    }
}

# 6. ทดสอบ Brands API (ถ้ามี token)
if ($adminToken) {
    Write-Host "`n🏷️ Testing Brands API..." -ForegroundColor Cyan
    
    # ทดสอบ Get Brands
    try {
        $headers = @{
            "Authorization" = "Bearer $adminToken"
        }
        
        $response = Invoke-WebRequest -Uri "http://localhost:4000/api/brands" -Headers $headers -UseBasicParsing -TimeoutSec 5
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Get Brands: Success" -ForegroundColor Green
            $brands = $response.Content | ConvertFrom-Json
            Write-Host "   Found $($brands.Count) brands" -ForegroundColor White
        } else {
            Write-Host "❌ Get Brands: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Get Brands: Connection failed" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 7. ทดสอบ Models API
if ($adminToken) {
    Write-Host "`n🔧 Testing Models API..." -ForegroundColor Cyan
    
    try {
        $headers = @{
            "Authorization" = "Bearer $adminToken"
        }
        
        $response = Invoke-WebRequest -Uri "http://localhost:4000/api/models" -Headers $headers -UseBasicParsing -TimeoutSec 5
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Get Models: Success" -ForegroundColor Green
            $models = $response.Content | ConvertFrom-Json
            Write-Host "   Found $($models.Count) models" -ForegroundColor White
        } else {
            Write-Host "❌ Get Models: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Get Models: Connection failed" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 8. ทดสอบ Parts API
if ($adminToken) {
    Write-Host "`n🔩 Testing Parts API..." -ForegroundColor Cyan
    
    try {
        $headers = @{
            "Authorization" = "Bearer $adminToken"
        }
        
        $response = Invoke-WebRequest -Uri "http://localhost:4000/api/parts" -Headers $headers -UseBasicParsing -TimeoutSec 5
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Get Parts: Success" -ForegroundColor Green
            $parts = $response.Content | ConvertFrom-Json
            Write-Host "   Found $($parts.Count) parts" -ForegroundColor White
        } else {
            Write-Host "❌ Get Parts: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Get Parts: Connection failed" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 9. ทดสอบ Customers API
if ($adminToken) {
    Write-Host "`n👥 Testing Customers API..." -ForegroundColor Cyan
    
    try {
        $headers = @{
            "Authorization" = "Bearer $adminToken"
        }
        
        $response = Invoke-WebRequest -Uri "http://localhost:4000/api/customers" -Headers $headers -UseBasicParsing -TimeoutSec 5
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Get Customers: Success" -ForegroundColor Green
            $customers = $response.Content | ConvertFrom-Json
            Write-Host "   Found $($customers.Count) customers" -ForegroundColor White
        } else {
            Write-Host "❌ Get Customers: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Get Customers: Connection failed" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 10. ทดสอบ Warranty API
if ($adminToken) {
    Write-Host "`n🛡️ Testing Warranty API..." -ForegroundColor Cyan
    
    try {
        $headers = @{
            "Authorization" = "Bearer $adminToken"
        }
        
        $response = Invoke-WebRequest -Uri "http://localhost:4000/api/warranties" -Headers $headers -UseBasicParsing -TimeoutSec 5
        
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Get Warranties: Success" -ForegroundColor Green
            $warranties = $response.Content | ConvertFrom-Json
            Write-Host "   Found $($warranties.Count) warranties" -ForegroundColor White
        } else {
            Write-Host "❌ Get Warranties: Failed (Status: $($response.StatusCode))" -ForegroundColor Red
        }
    } catch {
        Write-Host "❌ Get Warranties: Connection failed" -ForegroundColor Red
        Write-Host "   Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# 11. Summary
Write-Host "`n" + "=" * 50 -ForegroundColor Yellow
Write-Host "📊 Test Summary" -ForegroundColor Green
Write-Host "=" * 50 -ForegroundColor Yellow

Write-Host "`n🌐 System URLs:" -ForegroundColor Cyan
Write-Host "   Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "   Backend:  http://localhost:4000" -ForegroundColor White
Write-Host "   Mobile:   http://192.169.0.67:3000" -ForegroundColor White

Write-Host "`n🔑 Test Credentials:" -ForegroundColor Cyan
Write-Host "   Admin:      admin / admin123" -ForegroundColor White
Write-Host "   Technician: technician1 / tech123" -ForegroundColor White

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "   1. เปิด Browser ไปที่ http://localhost:3000" -ForegroundColor White
Write-Host "   2. Login ด้วย admin / admin123" -ForegroundColor White
Write-Host "   3. ทดสอบฟังก์ชั่นต่างๆ ตาม Manual Testing Guide" -ForegroundColor White
Write-Host "   4. ทดสอบบนมือถือที่ http://192.169.0.67:3000" -ForegroundColor White

Write-Host "`n📚 Documentation:" -ForegroundColor Cyan
Write-Host "   - TEST-SUITE.md: Complete test plan" -ForegroundColor White
Write-Host "   - MANUAL-TESTING-GUIDE.md: Step-by-step testing" -ForegroundColor White
Write-Host "   - test-automation.js: Automated API tests" -ForegroundColor White

Write-Host "`n✅ Test execution completed!" -ForegroundColor Green
Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
