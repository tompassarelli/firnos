#lang nisp

(module-file modules waybar
  (desc "Waybar status bar for Wayland")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    ;; SYSTEM: Install waybar package
    (set environment.systemPackages (with-pkgs waybar))

    ;; HOME-MANAGER: User configuration, dotfiles, and services
    (home-of 'username
      ;; Dotfiles: Main config (self-contained in module)
      (set xdg.configFile
        (att ("${\"waybar/config\"}"
              (att (source
                    (call 'config.lib.file.mkOutOfStoreSymlink
                          (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/waybar/config")))))
             ;; Dotfiles: Stylix-generated CSS (dynamic colors from theme)
             ;; Note: config.lib.stylix.colors comes from home-manager's stylix integration
             ("${\"waybar/stylix.css\"}"
              (att (text
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
                          "window#waybar, tooltip {"
                          "  background: alpha(@base00, ${toString config.stylix.opacity.desktop});"
                          "  color: @base05;"
                          "}"
                          ""
                          "tooltip {"
                          "  border-color: @base0D;"
                          "}"
                          ""
                          ".modules-left #workspaces button {"
                          "  border-bottom: 3px solid transparent;"
                          "}"
                          ".modules-left #workspaces button.focused,"
                          ".modules-left #workspaces button.active {"
                          "  border-bottom: 3px solid @base05;"
                          "}"
                          ""
                          ".modules-center #workspaces button {"
                          "  border-bottom: 3px solid transparent;"
                          "}"
                          ".modules-center #workspaces button.focused,"
                          ".modules-center #workspaces button.active {"
                          "  border-bottom: 3px solid @base05;"
                          "}"
                          ""
                          ".modules-right #workspaces button {"
                          "  border-bottom: 3px solid transparent;"
                          "}"
                          ".modules-right #workspaces button.focused,"
                          ".modules-right #workspaces button.active {"
                          "  border-bottom: 3px solid @base05;"
                          "}")))))
             ;; Dotfiles: Custom styles (self-contained in module)
             ("${\"waybar/style.css\"}"
              (att (source
                    (call 'config.lib.file.mkOutOfStoreSymlink
                          (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/waybar/style.css")))))
             ;; Dotfiles: Overview script (self-contained in module)
             ("${\"waybar/overview-waybar.py\"}"
              (att (source
                    (call 'config.lib.file.mkOutOfStoreSymlink
                          (s 'config.home.homeDirectory "/code/nixos-config/dotfiles/waybar/overview-waybar.py")))))))

      ;; Systemd service: Main waybar daemon
      (set systemd.user.services.waybar
        (att (Unit
              (att (Description "Highly customizable Wayland bar")
                   (PartOf (lst "graphical-session.target"))
                   (After (lst "graphical-session.target" "xdg-desktop-portal.service"))
                   (Requisite (lst "graphical-session.target"))))
             (Service
              (att (ExecStart (s "${pkgs.waybar}/bin/waybar"))
                   (Restart "on-failure")))
             (Install
              (att (WantedBy (lst "niri.service"))))))

      ;; Systemd service: Overview listener script
      (set systemd.user.services.waybar-overview
        (att (Unit
              (att (Description "Waybar visibility controller (overview + workspace switch)")
                   (PartOf (lst "graphical-session.target"))
                   (After (lst "waybar.service"))
                   (Requires (lst "waybar.service"))))
             (Service
              (att (ExecStart "%h/.config/waybar/overview-waybar.py")
                   (Restart "on-failure")))
             (Install
              (att (WantedBy (lst "niri.service")))))))))
