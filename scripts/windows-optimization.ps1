# Windows Optimization - Simple version from notes
Write-Host "Starting Windows optimization..."

# 1. Disable unnecessary services
Write-Host "Disabling unnecessary services..."
Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
Set-Service -Name WSearch -StartupType Disabled -ErrorAction SilentlyContinue

# 2. Clear event logs
Write-Host "Clearing event logs..."
wevtutil el | Foreach-Object {wevtutil cl "$_" 2>$null}

# 3. Run Disk Cleanup (automated version)
Write-Host "Running Disk Cleanup..."
cleanmgr /sagerun:1

Write-Host "Windows optimization completed!"