#lang nisp

(module-file modules windows-vm
  (desc "Windows VM via QEMU/KVM with virt-manager")
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    ;; Enable the libvirt daemon
    (set virtualisation.libvirtd
      (att (enable #t)
           (qemu
             (att (package pkgs.qemu_kvm)
                  ;; TPM emulation (required for Windows 11)
                  (swtpm.enable #t)))))

    ;; Virt-manager GUI
    (set programs.virt-manager.enable #t)

    ;; Add user to libvirtd group
    (set users.users
      (att ("${username}.extraGroups" (lst "libvirtd"))))

    ;; Useful packages
    (set environment.systemPackages
      (with-pkgs spice-gtk virtio-win))

    ;; Samba file sharing for Windows VM guests
    (set services.samba
      (att (enable #t)
           (settings
             (att (global
                    (att (workgroup "WORKGROUP")
                         ("${\"server string\"}" "NixOS")
                         (security "user")
                         ;; Only allow connections from the libvirt VM network
                         ("${\"hosts allow\"}" "192.168.122. 127.0.0.1 localhost")
                         ("${\"hosts deny\"}" "0.0.0.0/0")))
                  (shared
                    (att (path (s "/home/" username "/shared"))
                         (browseable "yes")
                         ("${\"read only\"}" "no")
                         ("${\"valid users\"}" username)
                         ("${\"create mask\"}" "0644")
                         ("${\"directory mask\"}" "0755")))))))

    ;; Open Samba ports only on the libvirt bridge interface
    (set networking.firewall.interfaces
      (att ("virbr0"
            (att (allowedTCPPorts (lst 445 139))
                 (allowedUDPPorts (lst 137 138))))))))

