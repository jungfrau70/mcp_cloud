# Container Course Tools Installation Script
# Run as Administrator

Write-Host "Container Course Tools Installation" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan

# Check if tools are already installed
Write-Host "`nChecking installed tools..." -ForegroundColor Yellow

# Check kubectl
try {
    $kubectlVersion = kubectl version --client 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ kubectl: Already installed" -ForegroundColor Green
    } else {
        Write-Host "✗ kubectl: Not installed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ kubectl: Not installed" -ForegroundColor Red
}

# Check Helm
try {
    $helmVersion = helm version --short 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Helm: Already installed" -ForegroundColor Green
    } else {
        Write-Host "✗ Helm: Not installed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Helm: Not installed" -ForegroundColor Red
}

# Check Google Cloud CLI
try {
    $gcloudVersion = gcloud --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Google Cloud CLI: Already installed" -ForegroundColor Green
    } else {
        Write-Host "✗ Google Cloud CLI: Not installed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Google Cloud CLI: Not installed" -ForegroundColor Red
}

# Install Helm if not installed
Write-Host "`nInstalling Helm..." -ForegroundColor Yellow
try {
    $helmVersion = helm version --short 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Download Helm
        $helmUrl = "https://get.helm.sh/helm-v3.12.0-windows-amd64.zip"
        $helmZip = "$env:TEMP\helm.zip"
        $helmDir = "C:\helm"
        
        if (!(Test-Path $helmDir)) {
            New-Item -ItemType Directory -Path $helmDir -Force | Out-Null
        }
        
        Invoke-WebRequest -Uri $helmUrl -OutFile $helmZip
        Expand-Archive -Path $helmZip -DestinationPath $helmDir -Force
        Remove-Item $helmZip
        
        # Add to PATH
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($currentPath -notlike "*$helmDir\windows-amd64*") {
            [Environment]::SetEnvironmentVariable("PATH", "$currentPath;$helmDir\windows-amd64", "User")
            $env:PATH += ";$helmDir\windows-amd64"
        }
        
        Write-Host "✓ Helm installed successfully" -ForegroundColor Green
    } else {
        Write-Host "✓ Helm already installed" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Helm installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Install Google Cloud CLI if not installed
Write-Host "`nInstalling Google Cloud CLI..." -ForegroundColor Yellow
try {
    $gcloudVersion = gcloud --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        # Download Google Cloud CLI
        $gcloudUrl = "https://dl.google.com/dl/cloudsdk/channels/rapid/GoogleCloudSDKInstaller.exe"
        $gcloudInstaller = "$env:TEMP\GoogleCloudSDKInstaller.exe"
        
        Invoke-WebRequest -Uri $gcloudUrl -OutFile $gcloudInstaller
        Write-Host "Please run the installer manually: $gcloudInstaller" -ForegroundColor Yellow
        Start-Process -FilePath $gcloudInstaller -Wait
        Remove-Item $gcloudInstaller
        
        Write-Host "✓ Google Cloud CLI installed successfully" -ForegroundColor Green
    } else {
        Write-Host "✓ Google Cloud CLI already installed" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Google Cloud CLI installation failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Final verification
Write-Host "`nFinal verification:" -ForegroundColor Green
Write-Host "==================" -ForegroundColor Green

# Check kubectl
try {
    $kubectlVersion = kubectl version --client 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ kubectl: Installed" -ForegroundColor Green
    } else {
        Write-Host "✗ kubectl: Not installed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ kubectl: Not installed" -ForegroundColor Red
}

# Check Helm
try {
    $helmVersion = helm version --short 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Helm: Installed" -ForegroundColor Green
    } else {
        Write-Host "✗ Helm: Not installed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Helm: Not installed" -ForegroundColor Red
}

# Check Google Cloud CLI
try {
    $gcloudVersion = gcloud --version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Google Cloud CLI: Installed" -ForegroundColor Green
    } else {
        Write-Host "✗ Google Cloud CLI: Not installed" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Google Cloud CLI: Not installed" -ForegroundColor Red
}

Write-Host "`nInstallation complete!" -ForegroundColor Cyan
Write-Host "Please open a new command prompt to use the tools." -ForegroundColor Yellow
