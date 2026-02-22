# check_apex.ps1
# A full check for frontend + backend + resources

$URL = "https://apexerp2-0.onrender.com"
$API = "$URL/api/health"

Write-Host "=== APEX ERP 2.0 Deployment Check ===`n"

# 1. Frontend URL check
Write-Host "1️⃣ Checking frontend URL..."
try {
    $resp = Invoke-WebRequest -Uri $URL -UseBasicParsing -Method Head
    Write-Host "✅ Frontend reachable. Status code:" $resp.StatusCode
} catch {
    Write-Host "❌ Frontend NOT reachable."
}

# 2. Backend API check
Write-Host "`n2️⃣ Checking backend API endpoint ($API)..."
try {
    $apiResp = Invoke-WebRequest -Uri $API -UseBasicParsing -Method Head
    Write-Host "✅ Backend API reachable. Status code:" $apiResp.StatusCode
} catch {
    Write-Host "⚠ Backend API may not be reachable."
}

# 3. Resource headers check
Write-Host "`n3️⃣ Checking main resource headers (JS/CSS/WASM)..."
try {
    $headers = Invoke-WebRequest -Uri $URL -UseBasicParsing -Method Head
    foreach ($key in $headers.Headers.Keys) {
        if ($key -match "Content-Type") {
            Write-Host "$key : $($headers.Headers[$key])"
        }
    }
    Write-Host "✅ Content-Type headers checked."
} catch {
    Write-Host "❌ Could not fetch resource headers."
}

# 4. Optional: check main JS/WASM files (common causes for 'Loading…')
Write-Host "`n4️⃣ Checking main frontend files..."
$resources = @(
    "main.js",
    "main.css",
    "blazor.webassembly.js",
    "dotnet.wasm"
)

foreach ($res in $resources) {
    try {
        $resResp = Invoke-WebRequest -Uri "$URL/$res" -UseBasicParsing -Method Head
        Write-Host "✅ $res found. Status:" $resResp.StatusCode
    } catch {
        Write-Host "⚠ $res NOT found!"
    }
}

Write-Host "`n=== Check complete. Look for ❌ or ⚠ messages above ==="