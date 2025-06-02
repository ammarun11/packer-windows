packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    windows-update = {
      version = "0.15.0"
      source  = "github.com/rgl/windows-update"
    }
  }
}

variable "accelerator" {
  type    = string
  default = "kvm"
}

variable "autounattend" {
  type    = string
  default = "./answer_files/2022-standard/Autounattend.xml"
}

variable "cpus" {
  type    = string
  default = "8"
}

variable "disk_size" {
  type    = string
  default = "16000"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "iso_checksum" {
  type    = string
  default = "sha256:3e4fa6d8507b554856fc9ca6079cc402df11a8b79344871669f0251535255325"
}

variable "iso_url" {
  type    = string
  default = "https://software-static.download.prss.microsoft.com/sg/download/888969d5-f34g-4e03-ac9d-1f9786c66749/SERVER_EVAL_x64FRE_en-us.iso"
}

variable "memory_size" {
  type    = string
  default = "12288"
}

variable "shutdown_command" {
  type    = string
  default = "%WINDIR%/system32/sysprep/sysprep.exe /generalize /oobe /shutdown /unattend:C:/Windows/Temp/Autounattend.xml"
}

variable "vm_name" {
  type    = string
  default = "devops_2022"
}

source "qemu" "win2022" {
  accelerator      = var.accelerator
  boot_wait        = "30s"
  boot_command     = ["<enter>"]
  communicator     = "winrm"
  cpus             = var.cpus
  disk_compression = "true"
  disk_interface   = "virtio"
  disk_size        = var.disk_size
  floppy_files     = [
    "${var.autounattend}", 
    "./scripts/0-firstlogin.bat", 
    "./scripts/1-fixnetwork.ps1", 
    "./scripts/50-enable-winrm.ps1", 
    "./answer_files/Firstboot/Firstboot-Autounattend.xml", 
    "./drivers/"
  ]

build {
  sources = ["source.qemu.win2022"]

  # Wait for WinRM to be available (first boot scripts run automatically via XML)
  provisioner "powershell" {
    inline = [
      "Write-Host 'WinRM is ready, first boot completed'",
      "Get-Date"
    ]
    timeout = "10m"
  }

  # Reboot after initial setup
  provisioner "windows-restart" {
    restart_check_command = "powershell -command \"& {Write-Output 'restarted.'}\""
    restart_timeout = "15m"
  }

  # Run Windows Update to fully patch system
  provisioner "windows-update" {
    search_criteria = "IsInstalled=0"
    filters = [
      "exclude:$_.Title -like '*Preview*'",
      "include:$true"
    ]
    update_limit = 25
  }

  # Install additional software
  provisioner "powershell" {
    scripts = ["./scripts/install-openssh-choco-vs.ps1"]
    timeout = "30m"
  }

  # Run Windows optimization script
  provisioner "powershell" {
    scripts = ["./scripts/windows-optimization.ps1"]
    timeout = "15m"
  }

  # Install misc tools
  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c C:/Windows/Temp/script.bat"
    remote_path     = "c:/Windows/Temp/script.bat"
    scripts = ["./scripts/70-install-misc.bat"]
    timeout = "15m"
  }

  # Compile dotnet assemblies
  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c C:/Windows/Temp/script.bat"
    remote_path     = "c:/Windows/Temp/script.bat"
    scripts = ["./scripts/80-compile-dotnet-assemblies.bat"]
    timeout = "15m"
  }

  # Compact the final image
  provisioner "windows-shell" {
    execute_command = "{{ .Vars }} cmd /c C:/Windows/Temp/script.bat"
    remote_path     = "c:/Windows/Temp/script.bat"
    scripts = ["./scripts/90-compact.bat"]
    timeout = "15m"
  }
}