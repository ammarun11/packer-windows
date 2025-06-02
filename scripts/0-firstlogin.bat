REM This is ran *first* by our Autounattendxml
REM See FirstLogonCommands/SynchronousCommand

echo "Starting first boot script" > C:\Windows\Temp\firstboot.log

REM Set high performance mode
powercfg /SETACTIVE 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
echo "Power configuration set" >> C:\Windows\Temp\firstboot.log

REM Copy our sysprep Autounattend for our post-packer first boot
copy "A:/Firstboot-Autounattend.xml" "C:/Windows/Temp/Autounattend.xml"
REM Copy the enable-winrm script, relied on by our post-packer autounattend script
copy "A:/50-enable-winrm.ps1" "C:/Windows/Temp/enable-winrm.ps1"
echo "Files copied" >> C:\Windows\Temp\firstboot.log

REM Set PowerShell Execution Policy
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"
echo "PowerShell execution policy set" >> C:\Windows\Temp\firstboot.log

REM Disable network location prompt
reg add /f "HKLM\System\CurrentControlSet\Control\Network\NewNetworkWindowOff"
echo "Network location prompt disabled" >> C:\Windows\Temp\firstboot.log

REM Disable hibernation
powercfg /h off 
echo "Hibernation disabled" >> C:\Windows\Temp\firstboot.log

REM Disable password expiration for devops user
wmic useraccount where "name='devops'" set PasswordExpires=FALSE
echo "Password expiration disabled for devops user" >> C:\Windows\Temp\firstboot.log

REM Install redhat certs for trust (if files exist)
if exist "a:/redhat-cert.cer" (
    certutil -addstore -f "TrustedPublisher" a:/redhat-cert.cer
    echo "RedHat cert installed" >> C:\Windows\Temp\firstboot.log
)
if exist "a:/redhat-cert-old.cer" (
    certutil -addstore -f "TrustedPublisher" a:/redhat-cert-old.cer
    echo "RedHat old cert installed" >> C:\Windows\Temp\firstboot.log
)

REM Enable RDP
netsh advfirewall firewall add rule name="Open Port 3389" dir=in action=allow protocol=TCP localport=3389
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Terminal Server" /v fDenyTSConnections /t REG_DWORD /d 0 /f
echo "RDP enabled" >> C:\Windows\Temp\firstboot.log

echo "First boot script completed successfully" >> C:\Windows\Temp\firstboot.log