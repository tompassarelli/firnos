#lang nisp

(module-file modules ironbar
  (desc "Ironbar status bar for Wayland")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    ;; SYSTEM: Install ironbar package (unstable for niri workspace support)
    (set 'environment.systemPackages (lst 'pkgs.unstable.ironbar))

    ;; HOME-MANAGER: User configuration, dotfiles, and services
    (home-of 'username
      ;; Dotfiles: Main config
      (nix-attrs-entries (att
        ((.> "xdg" "configFile" "\"ironbar/config.toml\"" "source")
         (call 'config.lib.file.mkOutOfStoreSymlink
           (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/ironbar/config.toml")))))

      ;; Dotfiles: Stylix-generated CSS (dynamic colors from theme)
      (nix-attrs-entries (att
        ((.> "xdg" "configFile" "\"ironbar/stylix.css\"" "text")
         (with-do 'config.lib.stylix.colors
           (ms "@define-color base00 #${base00};"
               "@define-color base01 #${base01};"
               "@define-color base02 #${base02};"
               "@define-color base03 #${base03};"
               "@define-color base04 #${base04};"
               "@define-color base05 #${base05};"
               "@define-color base06 #${base06};"
               "@define-color base07 #${base07};"
               "@define-color base08 #${base08};"
               "@define-color base09 #${base09};"
               "@define-color base0A #${base0A};"
               "@define-color base0B #${base0B};"
               "@define-color base0C #${base0C};"
               "@define-color base0D #${base0D};"
               "@define-color base0E #${base0E};"
               "@define-color base0F #${base0F};"
               ""
               "* {"
               "  font-family: \"${config.stylix.fonts.monospace.name}\";"
               "  font-size: ${toString config.stylix.fonts.sizes.desktop}pt;"
               "}"
               ""
               ".background {"
               "  background: alpha(@base00, ${toString config.stylix.opacity.desktop});"
               "  color: @base05;"
               "}"
               ""
               "tooltip {"
               "  background: alpha(@base00, ${toString config.stylix.opacity.desktop});"
               "  color: @base05;"
               "  border-color: @base0D;"
               "}")))))

      ;; Dotfiles: Custom styles
      (nix-attrs-entries (att
        ((.> "xdg" "configFile" "\"ironbar/style.css\"" "source")
         (call 'config.lib.file.mkOutOfStoreSymlink
           (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/ironbar/style.css")))))

      ;; Dotfiles: Overview script
      (nix-attrs-entries (att
        ((.> "xdg" "configFile" "\"ironbar/overview-ironbar.py\"" "source")
         (call 'config.lib.file.mkOutOfStoreSymlink
           (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/ironbar/overview-ironbar.py")))))

      ;; Dotfiles: Battery script
      (nix-attrs-entries (att
        ((.> "xdg" "configFile" "\"ironbar/battery.sh\"" "source")
         (call 'config.lib.file.mkOutOfStoreSymlink
           (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/ironbar/battery.sh")))))

      ;; Systemd service: Main ironbar daemon
      (set 'systemd.user.services.ironbar
        (att
          ('Unit (att
            ('Description "Customizable GTK4 status bar for Wayland")
            ('PartOf (lst "graphical-session.target"))
            ('After (lst "graphical-session.target"))
            ('Requisite (lst "graphical-session.target"))))
          ('Service (att
            ('ExecStart (s 'pkgs.unstable.ironbar "/bin/ironbar"))
            ('Restart "on-failure")))
          ('Install (att
            ('WantedBy (lst "niri.service"))))))

      ;; Systemd service: Overview listener script
      (set 'systemd.user.services.ironbar-overview
        (att
          ('Unit (att
            ('Description "Ironbar overview listener script")
            ('PartOf (lst "graphical-session.target"))
            ('After (lst "ironbar.service"))
            ('Requires (lst "ironbar.service"))))
          ('Service (att
            ('ExecStart "%h/.config/ironbar/overview-ironbar.py")
            ('Restart "on-failure")))
          ('Install (att
            ('WantedBy (lst "niri.service")))))))))
