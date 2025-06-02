==> qemu.win2022: Gracefully halting virtual machine...
2025/06/02 12:54:59 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 12:54:59 Executing shutdown command: %!W(MISSING)INDIR%!/(MISSING)system32/sysprep/sysprep.exe /generalize /oobe /shutdown /unattend:C:/Windows/Temp/Autounattend.xml
2025/06/02 12:54:59 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 12:54:59 [INFO] starting remote command: %!W(MISSING)INDIR%!/(MISSING)system32/sysprep/sysprep.exe /generalize /oobe /shutdown /unattend:C:/Windows/Temp/Autounattend.xml
2025/06/02 12:55:41 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 12:55:41 [INFO] command '%!W(MISSING)INDIR%!/(MISSING)system32/sysprep/sysprep.exe /generalize /oobe /shutdown /unattend:C:/Windows/Temp/Autounattend.xml' exited with code: 0
2025/06/02 12:55:41 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 12:55:41 Waiting max 5m0s for shutdown to complete
2025/06/02 12:55:48 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 12:55:48 VM shut down.
==> qemu.win2022: Converting hard drive...
2025/06/02 12:55:48 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 12:55:48 Executing qemu-img: []string{"convert", "-c", "-O", "qcow2", "output-win_2022/packer-win2022", "output-win_2022/packer-win2022.convert"}
2025/06/02 13:04:14 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 13:04:14 stdout:
2025/06/02 13:04:14 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 13:04:14 stderr:
2025/06/02 13:04:15 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 13:04:15 failed to unlock port lockfile: close tcp 127.0.0.1:5993: use of closed network connection
2025/06/02 13:04:15 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 13:04:15 failed to unlock port lockfile: close tcp 127.0.0.1:2685: use of closed network connection
2025/06/02 13:04:15 packer-plugin-qemu_v1.1.2_x5.0_linux_amd64 plugin: 2025/06/02 13:04:15 Deleting floppy disk: /tmp/packer253141806
2025/06/02 13:04:15 [INFO] (telemetry) ending qemu.win2022
==> Wait completed after 41 minutes 15 seconds
==> Builds finished. The artifacts of successful builds are:
2025/06/02 13:04:15 machine readable: qemu.win2022,artifact-count []string{"1"}
Build 'qemu.win2022' finished after 41 minutes 15 seconds.

==> Wait completed after 41 minutes 15 seconds

==> Builds finished. The artifacts of successful builds are:
2025/06/02 13:04:15 machine readable: qemu.win2022,artifact []string{"0", "builder-id", "transcend.qemu"}
2025/06/02 13:04:15 machine readable: qemu.win2022,artifact []string{"0", "id", "VM"}
2025/06/02 13:04:15 machine readable: qemu.win2022,artifact []string{"0", "string", "VM files in directory: output-win_2022"}
2025/06/02 13:04:15 machine readable: qemu.win2022,artifact []string{"0", "files-count", "1"}
2025/06/02 13:04:15 machine readable: qemu.win2022,artifact []string{"0", "file", "0", "output-win_2022/packer-win2022"}
2025/06/02 13:04:15 machine readable: qemu.win2022,artifact []string{"0", "end"}
--> qemu.win2022: VM files in directory: output-win_2022
2025/06/02 13:04:15 [INFO] (telemetry) Finalizing.
2025/06/02 13:04:15 waiting for all plugin processes to complete...
2025/06/02 13:04:15 /data/workdir/amr/packer-windows/packer: plugin process exited
2025/06/02 13:04:15 /data/workdir/amr/packer-windows/packer: plugin process exited
2025/06/02 13:04:15 /data/workdir/amr/packer-windows/packer: plugin process exited
2025/06/02 13:04:15 /data/workdir/amr/packer-windows/packer: plugin process exited
2025/06/02 13:04:15 /root/.config/packer/plugins/github.com/hashicorp/qemu/packer-plugin-qemu_v1.1.2_x5.0_linux_amd64: plugin process exited
2025/06/02 13:04:15 /data/workdir/amr/packer-windows/packer: plugin process exited
2025/06/02 13:04:15 /data/workdir/amr/packer-windows/packer: plugin process exited
2025/06/02 13:04:15 /data/workdir/amr/packer-windows/packer: plugin process exited

real    41m16.057s
user    62m32.744s
sys     10m3.267s