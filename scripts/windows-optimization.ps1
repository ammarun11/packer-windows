# Disable unnecessary services
Set-Service -Name DiagTrack -StartupType Disabled
Set-Service -Name WSearch -StartupType Disabled

# Clear all event logs
wevtutil el | Foreach-Object {wevtutil cl "$_"}

# Run Disk Cleanup silently (configure sagerun before or manually)
cleanmgr /sagerun:1