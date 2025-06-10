## Objective

1. **User Guide Instructions:**
   - Provide detailed instructions in your user guide on where and how to download the necessary binaries, images, and drivers.
   - Include guidance on where to place these files within the project folder structure.

2. **WinRM Configuration:**
   - Ensure that WinRM is configured securely.
   - Make sure it is not accessible from outside the host OS, such as from other machines on the network.

##

-----

## User Guide: Setting Up Your Packer Build Environment

This guide provides clear, step-by-step instructions for downloading the required files and arranging your project directory to successfully build a Windows Server image with Packer.

-----

### 1\. Download Prerequisites 📥

You'll need to gather three main components before starting the build: the Packer software, a Windows Server ISO, and the necessary VirtIO drivers.

#### 📦 Packer Binary

First, ensure the Packer command-line tool is installed on your system. You can download it directly from the official HashiCorp website.

  * **Download Location:** [https://developer.hashicorp.com/packer/install](https://developer.hashicorp.com/packer/install)

#### 🪟 Windows Server ISO Image

The project can be configured to use a Windows ISO from either a public URL or a local file path.

  * **Using a Public URL:** If you have a direct download link, set it as the default for the `iso_url` variable in your Packer template. A helpful tool for finding official links is **Mido** ([https://github.com/ElliotKillick/Mido](https://github.com/ElliotKillick/Mido)).

    ```hcl
    variable "iso_url" {
      type    = string
      default = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
    }
    ```

  * **Using a Local File:** If you've already downloaded the ISO, update the `iso_url` variable to point to its local path and provide the corresponding SHA256 checksum.

    ```hcl
    variable "iso_url" {
      type    = string
      default = "/home/ubuntu/iso/windows-server-2022.iso"
    }

    variable "iso_checksum" {
      type    = string
      default = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
    }
    ```

    > ⚠️ **Important:** You must replace the default `iso_checksum` value with the actual SHA256 hash of your local ISO file. On Linux, you can get this by running `sha256sum /path/to/your/file.iso`.

#### 🚗 VirtIO Drivers for Windows

High-performance VirtIO drivers are essential for the VM's storage and network devices.

  * **Step 1: Download the Driver ISO**
    Grab the latest stable `virtio-win.iso` from the official Fedora Project repository.

      * **Download Location:** [https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/](https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/)

  * **Step 2: Extract the ISO**
    Use `7-Zip` to extract the contents. If it's not installed on your Ubuntu/Debian system, run `sudo apt update && sudo apt install p7zip-full`. Then, extract the files:

    ```bash
    7z x virtio-win.iso -o./virtio-extracted
    ```

  * **Step 3: Select and Copy Required Drivers**
    From the `virtio-extracted` folder, copy the drivers for the components listed below. These are the key drivers needed for a Windows Server guest.

      * Balloon (Memory Management)
      * NetKVM (Networking)
      * viostor (Block Storage)
      * vioscsi (SCSI Storage)
      * viorng (RNG Device)
      * vioser (Serial Port)
      * `Virtio_Win_Red_Hat_CA.cer` (Signing Certificate)

-----

### 2\. Arrange Your Project Folder 📂

For the build to succeed, all components must be placed in their correct locations. The selected VirtIO drivers must go inside the `drivers/w10` subdirectory.

Your final project structure should look like this:

```
packer-windows/
├── drivers/
│   └── w10/
│       ├── balloon.cat, .inf, .sys, ...
│       ├── netkvm.cat, .inf, .sys, ...
│       ├── vioscsi.cat, .inf, .sys, ...
│       ├── vioser.cat, .inf, .sys, ...
│       ├── viostor.cat, .inf, .sys, ...
│       ├── viorng.cat, .inf, .sys, ...
│       └── Virtio_Win_Red_Hat_CA.cer
├── scripts/
│   └── 50-enable-winrm.ps1
└── win2022.pkr.hcl
```

-----

### 3\. Secure WinRM Configuration 🔒

The WinRM connection used by Packer is configured to be secure by design, ensuring it isn't accessible from outside your local machine.

  * **Encrypted:** All communication between Packer and the guest VM is encrypted end-to-end using **SSL/TLS (HTTPS)**.
  * **Isolated:** The Packer builder **does not expose the VM's ports to your external network**. The WinRM connection is limited to a secure, private channel on your local machine only.
  * **Secure by Design:** The provisioning script (`50-enable-winrm.ps1`) automatically generates a **unique, self-signed certificate** during the build. Because this certificate is only trusted for the temporary, local connection, it prevents any possibility of outside interference or unauthorized access.