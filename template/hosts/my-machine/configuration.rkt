#lang nisp

;; My machine configuration
;; Enable the modules you want from FirnOS
(host-file
  ;; ============ REQUIRED ============
  (set myConfig.modules.system.stateVersion "25.05")  ; Set to your NixOS install version
  (set myConfig.modules.users.username "yourname")    ; Change this!

  ;; ============ SYSTEM ============
  (enable myConfig.modules.nix-settings
          myConfig.modules.boot
          myConfig.modules.users
          myConfig.modules.networking
          myConfig.modules.timezone
          myConfig.modules.ssh)

  ;; ============ HARDWARE ============
  (enable myConfig.modules.pipewire
          myConfig.modules.bluetooth
          myConfig.modules.input)

  (set myConfig.modules.kanata
    (att (enable #t)
         (capsLockEscCtrl #t)))

  ;; ============ BUNDLES ============
  (enable myConfig.bundles.terminal
          myConfig.bundles.cli-tools
          myConfig.bundles.desktop)
  (set myConfig.bundles.theming
    (att (enable #t)
         (stylix.chosenTheme "tokyo-night-dark")))
  (enable myConfig.bundles.auth
          myConfig.bundles.development
          myConfig.bundles.browsers
          myConfig.bundles.media
          myConfig.bundles.communication
          myConfig.bundles.productivity)

  ;; Required: nisp/firn-build pipeline needs racket on the system
  (enable myConfig.bundles.racket)

  ;; ============ MODULES ============
  (enable myConfig.modules.neovim
          myConfig.modules.password))
