#lang nisp

(module-file modules boot
  (desc "boot configuration")
  (config-body
    ;; Use the systemd-boot EFI boot loader
    (set 'boot.loader.systemd-boot.enable #t)
    (set 'boot.loader.efi.canTouchEfiVariables #t)

    ;; Use testing kernel (6.18-rc) for mt7925e WiFi fixes
    ;; The mt7925 driver has deadlock bugs in MLO code causing system hangs
    ;; (set boot.kernelPackages pkgs.linuxPackages_testing)

    ;; Kernel modules for hardware support
    ;; Load uinput module early for kanata
    (set 'boot.kernelModules (lst "uinput"))

    ;; Disable VPE (Video Processing Engine) to fix suspend/resume crashes on RDNA 3
    ;; VPE queue reset fails during resume, corrupting driver state and causing later freezes
    (set 'boot.kernelParams (lst "amdgpu.vpe_enable=0"))))
