# Install and configure software for Windows Server 2022
Write-Host "Starting software installation..."

# Refresh environment variables to pick up Chocolatey
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")

# Check if Chocolatey is available, if not install it
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    
    # Refresh PATH again after Chocolatey install
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    Write-Host "Chocolatey installed successfully"
}

# Configure OpenSSH Server
Write-Host "Configuring OpenSSH Server..."
try {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 -ErrorAction Stop
    Start-Service sshd -ErrorAction Stop
    Set-Service -Name sshd -StartupType Automatic -ErrorAction Stop
    Write-Host "OpenSSH Server configured successfully"
} catch {
    Write-Warning "OpenSSH Server configuration failed: $($_.Exception.Message)"
}

# Install Visual Studio Build Tools 2022
Write-Host "Installing Visual Studio Build Tools 2022..."
try {
    choco install visualstudio2022buildtools -y --version=117.8.0
    Write-Host "Visual Studio Build Tools installed successfully"
} catch {
    Write-Warning "Visual Studio Build Tools installation failed: $($_.Exception.Message)"
}

# Install other tools with specific versions from your notes
$packages = @{
    "git" = $null  # Latest version
    "7zip" = "23.1.0"
    "wget" = "1.21.4"  
    "curl" = "8.4.0"
    "jq" = "1.7.0"
    "cmake" = "3.27.8"
}

foreach ($package in $packages.GetEnumerator()) {
    try {
        Write-Host "Installing $($package.Name)..."
        if ($package.Value) {
            choco install $package.Name -y --version=$($package.Value) --no-progress --limit-output
        } else {
            choco install $package.Name -y --no-progress --limit-output
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$($package.Name) installed successfully"
        } else {
            Write-Warning "$($package.Name) installation returned exit code $LASTEXITCODE"
        }
    } catch {
        Write-Warning "Error installing $($package.Name): $($_.Exception.Message)"
    }
}

# Disable unnecessary services for optimization
Write-Host "Disabling unnecessary services..."
try {
    Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    Set-Service -Name WSearch -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "Services disabled successfully"
} catch {
    Write-Warning "Service configuration failed: $($_.Exception.Message)"
}

Write-Host "Software installation completed"