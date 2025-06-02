# Simple WinRM configuration for Packer (HTTP only)
Write-Host "Configuring WinRM for Packer (HTTP only)..."

# Enable WinRM service
Enable-PSRemoting -Force -SkipNetworkProfileCheck
Set-Service -Name WinRM -StartupType Automatic
Start-Service -Name WinRM

# Configure WinRM for HTTP (unencrypted for Packer)
winrm quickconfig -q -force
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'

# Ensure HTTP listener exists
$httpListener = Get-ChildItem WSMan:\localhost\Listener | Where-Object {$_.Keys -like "TRANSPORT=HTTP"}
if (-not $httpListener) {
    Write-Host "Creating HTTP listener..."
    winrm create winrm/config/Listener?Address=*+Transport=HTTP
}

# Configure firewall for HTTP (port 5985)
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new profile=any enable=yes
New-NetFirewallRule -DisplayName "WinRM HTTP Packer" -Direction Inbound -LocalPort 5985 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue

# Set network profile to Private
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue

# Disable UAC for better compatibility
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Force

# Set LocalAccountTokenFilterPolicy for local account access
$tokenPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
New-ItemProperty -Path $tokenPath -Name "LocalAccountTokenFilterPolicy" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue

Write-Host "WinRM HTTP configuration completed"

# Test WinRM HTTP
try {
    $result = winrm enumerate winrm/config/listener
    Write-Host "WinRM listeners configured:"
    Write-Host $result
} catch {
    Write-Host "Warning: Could not enumerate WinRM listeners: $($_.Exception.Message)"
}

# Restart WinRM service
Restart-Service -Name WinRM -Force
Write-Host "WinRM service restarted"