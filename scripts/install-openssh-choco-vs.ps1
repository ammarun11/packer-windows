# Install Chocolatey packages without specific versions
Write-Host "Installing Chocolatey packages..."

# Install packages without version constraints (use latest)
$packages = @(
    "git",
    "curl",
    "jq",
    "wget",
    "vim",
    "7zip",
    "putty",
    "notepadplusplus"
)

foreach ($package in $packages) {
    try {
        Write-Host "Installing $package..."
        choco install $package -y --no-progress --limit-output
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$package installed successfully"
        } else {
            Write-Warning "$package installation failed, but continuing..."
        }
    } catch {
        Write-Warning "Error installing $package`: $($_.Exception.Message)"
    }
}

# Install Visual Studio Build Tools (if needed)
try {
    Write-Host "Installing Visual Studio Build Tools..."
    choco install visualstudio2022buildtools -y --no-progress --limit-output
    Write-Host "Visual Studio Build Tools installed"
} catch {
    Write-Warning "Visual Studio Build Tools installation failed: $($_.Exception.Message)"
}

Write-Host "Chocolatey package installation completed"