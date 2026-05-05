#lang nisp

;; Host-specific config for whiterabbit (Framework 13 laptop)
(host-file
  ;; ============ REQUIRED ============
  (set myConfig.modules.system.stateVersion "25.05")
  (enable myConfig.modules.users)
  (set myConfig.modules.users.username "tom")

  ;; ============ SYSTEM ============
  (enable myConfig.modules.nix-settings
          myConfig.modules.boot
          myConfig.modules.networking
          myConfig.modules.remmina
          myConfig.modules.timezone
          myConfig.modules.ssh
          myConfig.modules.auto-upgrade)

  ;; ============ HARDWARE ============
  (enable myConfig.modules.framework
          myConfig.modules.fwupd
          myConfig.modules.pipewire
          myConfig.modules.bluetooth
          myConfig.modules.input)
  (set myConfig.modules.piper.enable #f)
  (enable myConfig.modules.g203-led)

  (set myConfig.modules.kanata
    (att (enable #t)
         (configFile (p "../../dotfiles/kanata/kanata.kbd"))
         (port 7070)
         (devices (lst "/dev/input/event0"
                       "/dev/input/by-id/usb-Kingsis_Peripherals_ZOWIE_Gaming_mouse-event-mouse"
                       "/dev/input/by-id/usb-Logitech_G102_LIGHTSYNC_Gaming_Mouse_2072387E5847-event-mouse"))))
  (enable myConfig.modules.glide)

  ;; ============ BUNDLES ============
  (enable myConfig.bundles.terminal
          myConfig.bundles.cli-tools)
  (set myConfig.bundles.desktop
    (att (enable #t)
         (mako.enable #f)))
  (set myConfig.bundles.theming
    (att (enable #t)
         (stylix.chosenTheme "everforest-dark-hard")))
  (enable myConfig.bundles.auth
          myConfig.bundles.development
          myConfig.bundles.javascript
          myConfig.bundles.python)
  (set myConfig.bundles.database
    (att (enable #t)
         (postgresql.enable #f)))
  (set myConfig.bundles.rust
    (att (enable #t)
         (bevy.enable #f)))
  (set myConfig.bundles.csharp.enable #f)
  (set myConfig.bundles.lisp
    (att (enable #t)
         (lem.enable #t)))
  (enable myConfig.bundles.racket
          myConfig.bundles.doom-emacs)
  (set myConfig.bundles.browsers
    (att (enable #t)
         (firefox.palefox.enable #t)
         (chrome.enable #t)
         (zen-browser.enable #t)
         (qutebrowser.enable #t)))
  (set myConfig.bundles.gaming
    (att (enable #t)
         (lutris.enable #t)
         (wowup.enable #t)))
  (set myConfig.bundles.creative
    (att (enable #t)
         (blender.enable #f)
         (gimp.enable #f)
         (godot.enable #f)))
  (set myConfig.bundles.media
    (att (enable #t)
         (youtube-music.enable #f)))
  (enable myConfig.bundles.communication)
  (set myConfig.bundles.productivity
    (att (enable #t)
         (obsidian.enable #t)
         (todoist.enable #f)
         (pomodoro.enable #f)
         (libreoffice.enable #f)))
  (set myConfig.bundles.printing.enable #f)
  (set myConfig.bundles.vpn
    (att (enable #t)
         (protonvpn-cli.enable #f)))

  ;; ============ MODULES ============
  (set myConfig.modules.guix.enable #f)
  (enable myConfig.modules.neovim
          myConfig.modules.password
          myConfig.modules.mini-serve
          myConfig.modules.awscli
          myConfig.modules.parted
          myConfig.modules.unixodbc
          myConfig.modules.nix-ld
          myConfig.modules.appimage
          myConfig.modules.codex
          myConfig.modules.vscode
          myConfig.modules.windows-vm))
