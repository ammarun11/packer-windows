# Windows / Qemu(KVM/Libvirt) Packer Templates

Builds Windows Server 2022 images suitable for consumption with QEMU and libvirt.

## Intent

Images have the following:

* Fully up to date (see `windows-update` provisioner)
* Access mechanisms:
  * WinRM, RDP, and SSH enabled by default
  * Username / password is "devops/devops"
* Installed packages
  * Chocolatey
  * OpenSSH Server
  * Visual Studio Build Tools 2022
  * Development tools (git, curl, wget, jq, cmake, 7zip)
  * QEMU guest additions
  * VirtIO drivers

## Prerequisites

* QEMU 8.1.5 or above
* Packer 1.9.4 or above (or use included binary)
* KVM support on host

## Packer Binary

This repository includes a pre-compiled Packer binary (`packer`) for convenience. If you prefer to use your system's Packer installation, ensure it meets the version requirements above.

To use the included binary:
```bash
# Make it executable (if needed)
chmod +x packer

# Use the local binary
./packer build template-win2022.pkr.hcl
```

## Building

```bash
# Initialize plugins first (using included binary)
./packer init template-win2022.pkr.hcl

# Build Windows Server 2022 image
./packer build template-win2022.pkr.hcl

# Build with UI support (useful for debugging)
./packer build -var=headless=false template-win2022.pkr.hcl

# Build with a different ISO
# Ensure to specify a new checksum!
./packer build -var=iso_checksum=sha256:xxx -var=iso_url=http://foo.com template-win2022.pkr.hcl

# Use a different autounattend file
./packer build -var=autounattend=./answer_files/custom/Autounattend.xml template-win2022.pkr.hcl
```

## Building faster

* Remove the `windows-update` provisioner
  * This takes almost as long as the initial installation
* Comment out software installation provisioners if not needed
* Disable Windows optimization script for faster builds:
  ```bash
  # Comment out the windows-optimization.ps1 provisioner in the .pkr.hcl file
  ```

## Customizations

### General customizations

Most of the time, you want to edit:
* `scripts/0-firstlogin.bat` - First boot configuration
* `scripts/install-openssh-choco-vs.ps1` - Software installation
* `scripts/windows-optimization.ps1` - System optimization
* `scripts/70-install-misc.bat` - Additional tools

### Software Versions

The following software is installed with specific versions (based on GitLab CI requirements):
* Visual Studio Build Tools 2022 (v117.8.0)
* 7zip (v23.1.0)
* wget (v1.21.4)
* curl (v8.4.0)
* jq (v1.7.0)
* cmake (v3.27.8)
* git (latest)

To customize versions, edit `scripts/install-openssh-choco-vs.ps1`.

### Toggling sysprep

These images will sysprep on first boot by default. This can be disabled by specifying:

```bash
packer build -var=shutdown_command="shutdown /s /t 10 /f /d p:4:1 /c \"Packer Shutdown\"" devops-win2022.pkr.hcl
```

### Network Configuration

The build is configured for:
* HTTP WinRM (port 5985) for Packer communication
* HTTPS WinRM (port 5986) for production use
* SSH (port 22) for alternative access
* RDP (port 3389) for GUI access

### Checking host readiness

A file-based lock is implemented:
* Creates `C:/not-yet-finished` in `0-firstlogin.bat`
* Deleted once `Firstboot-Autounattend.xml` has finished running (post-sysprep)

**Recommended check:** Monitor for the absence of `C:/not-yet-finished` file to confirm the host has finished sysprepping and is ready for use.

## File Structure

```
.
├── packer                           # Pre-compiled Packer binary (v1.12.0)
├── packer_1.12.0_linux_amd64.zip   # Original Packer download
├── template-win2022.pkr.hcl        # Main Packer configuration
├── answer_files/
│   ├── 2022-standard/
│   │   └── Autounattend.xml         # Main installation answer file
│   └── Firstboot/
│       └── Firstboot-Autounattend.xml  # Post-sysprep configuration
├── scripts/
│   ├── 0-firstlogin.bat            # First boot setup script
│   ├── 1-fixnetwork.ps1            # Network configuration
│   ├── 50-enable-winrm.ps1         # WinRM configuration
│   ├── install-openssh-choco-vs.ps1 # Software installation
│   ├── windows-optimization.ps1     # System optimization
│   ├── 70-install-misc.bat         # Additional tools
│   ├── 80-compile-dotnet-assemblies.bat # .NET optimization
│   └── 90-compact.bat              # Disk space optimization
└── drivers/                        # VirtIO and RedHat drivers
    ├── amd64/w10/                   # VirtIO drivers for Windows
    ├── redhat-cert.cer              # RedHat certificate
    └── redhat-cert-old.cer          # Legacy RedHat certificate
```

## Troubleshooting

### Common Issues

1. **Build hangs at Windows Update registry configuration:**
   - Check `C:\Windows\Temp\firstboot.log` for detailed progress
   - Registry operations can take time on first boot

2. **WinRM connection errors:**
   - Ensure `winrm_use_ssl = false` for HTTP connection
   - Check firewall settings allow WinRM traffic

3. **Chocolatey command not found:**
   - PATH variables need refresh after Chocolatey installation
   - Script handles this automatically with environment variable refresh

4. **Disk Cleanup hangs:**
   - The `/sagerun:1` profile may not exist
   - Comment out `cleanmgr /sagerun:1` line for automated builds

### Debug Mode

Run with VNC access for debugging:
```bash
./packer build -var=headless=false template-win2022.pkr.hcl
```

Connect via VNC to `localhost:5991-5999` to see the installation progress.

## Output

The build creates a QCOW2 image in `output-win_2022/` directory, ready for use with QEMU/KVM and libvirt.

### Disk Management

**Default Configuration:**
- The Windows Server 2022 image is created with a 16GB disk by default
- Actual Windows installation uses approximately 15GB of space

**Expanding Disk Size:**
If you need more disk space after deployment, you can expand the image:

```bash
# Resize the QCOW2 image (example: add 100GB)
qemu-img resize /path/to/your/image.qcow2 +100G

# Alternative: resize to specific total size
qemu-img resize /path/to/your/image.qcow2 116G
```

**Windows Configuration:**
After resizing the image file, boot the Windows Server 2022 and:
1. Open **Disk Management** (`diskmgmt.msc`)
2. Right-click on the C: drive
3. Select **Extend Volume**
4. Follow the wizard to use the additional space

**Note:** Always shutdown the VM before resizing the disk image to avoid data corruption.