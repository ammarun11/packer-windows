# Install OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Start-Service sshd
Set-Service -Name sshd -StartupType Automatic

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Visual Studio Build Tools 2022 (specific version)
choco install visualstudio2022buildtools -y --version=117.8.0

# Install additional tools
choco install -y git 7zip --version=23.1.0 wget --version=1.21.4 curl --version=8.4.0 jq --version=1.7.0 cmake --version=3.27.8

# Optional: Launch VS Installer UI to modify workloads
Start-Process -FilePath "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
