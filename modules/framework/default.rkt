#lang nisp

(module-file modules framework
  (desc "Framework Computer specific tools")
  (config-body
    (set 'environment.systemPackages (with-pkgs 'framework-tool))

    ;; Disable suspend on lid close (sleep/wake issues)
    (set 'services.logind.settings.Login
      (att ('HandleLidSwitch "ignore")
           ('HandleLidSwitchExternalPower "ignore")))

    ;; MT7925e WiFi stability fixes
    ;; - disable_clc: Disables Country Location Code auto-detection (6GHz issues)
    ;; - disable_aspm: Disables PCI power management (prevents race conditions during roaming)
    (set 'boot.extraModprobeConfig
      (ms "options mt7925_common disable_clc=1"
          "options mt7925e disable_aspm=1"))))
