#lang nisp

(module-file modules quickshell
  (desc "Quickshell (Qt6/QML) status bar")
  (extra-args inputs)
  (lets ([username config.myConfig.modules.users.username]
         [monoFont config.stylix.fonts.monospace.name]))
  (config-body
    ;; SYSTEM: Install quickshell
    (set environment.systemPackages
      (lst (nix-ident "inputs.quickshell.packages.${pkgs.system}.default")))

    ;; User needs input group for evdev key release detection
    (set "users.users.${username}.extraGroups" (lst "input"))

    ;; HOME-MANAGER: Dotfiles and services
    (home-of username
      ;; Dotfiles: QML config (live-edit symlinks)
      (set "xdg.configFile.\"quickshell/shell.qml\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/shell.qml")))
      (set "xdg.configFile.\"quickshell/Bar.qml\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/Bar.qml")))
      (set "xdg.configFile.\"quickshell/NiriListener.qml\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/NiriListener.qml")))
      (set "xdg.configFile.\"quickshell/BarState.qml\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/BarState.qml")))
      (set "xdg.configFile.\"quickshell/WorkspaceRow.qml\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/WorkspaceRow.qml")))
      (set "xdg.configFile.\"quickshell/WorkspacePopup.qml\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/WorkspacePopup.qml")))
      (set "xdg.configFile.\"quickshell/key-release-monitor.py\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/key-release-monitor.py")))
      (set "xdg.configFile.\"quickshell/LayoutConfig.qml\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/LayoutConfig.qml")))
      (set "xdg.configFile.\"quickshell/NotificationPopup.qml\".source"
        (call config.lib.file.mkOutOfStoreSymlink
              (s config.home.homeDirectory "/code/nixos-config/dotfiles/quickshell/NotificationPopup.qml")))

      ;; Generate stylix colors for quickshell.
      ;; `with config.lib.stylix.colors;` brings base00..base0F into scope so
      ;; the ${baseXX} interpolations below resolve to their hex values.
      (set "xdg.configFile.\"quickshell/StylixColors.qml\".text"
        (with-do config.lib.stylix.colors
          (ms "import QtQuick"
              ""
              "QtObject {"
              (s "    readonly property color base00: \"#" base00 "\"")
              (s "    readonly property color base01: \"#" base01 "\"")
              (s "    readonly property color base02: \"#" base02 "\"")
              (s "    readonly property color base03: \"#" base03 "\"")
              (s "    readonly property color base04: \"#" base04 "\"")
              (s "    readonly property color base05: \"#" base05 "\"")
              (s "    readonly property color base06: \"#" base06 "\"")
              (s "    readonly property color base07: \"#" base07 "\"")
              (s "    readonly property color base08: \"#" base08 "\"")
              (s "    readonly property color base09: \"#" base09 "\"")
              (s "    readonly property color base0A: \"#" base0A "\"")
              (s "    readonly property color base0B: \"#" base0B "\"")
              (s "    readonly property color base0C: \"#" base0C "\"")
              (s "    readonly property color base0D: \"#" base0D "\"")
              (s "    readonly property color base0E: \"#" base0E "\"")
              (s "    readonly property color base0F: \"#" base0F "\"")
              (s "    readonly property string fontFamily: \"" monoFont "\"")
              "}")))

      ;; Systemd service: Quickshell daemon
      (set systemd.user.services.quickshell
        (att
          (Unit (att (Description "Quickshell widget framework")
                     (PartOf (lst "graphical-session.target"))
                     (After (lst "graphical-session.target"))
                     (Requisite (lst "graphical-session.target"))))
          (Service (att
            (ExecStart (s (nix-ident "inputs.quickshell.packages.${pkgs.system}.default") "/bin/qs"))
            (Restart "on-failure")))
          (Install (att (WantedBy (lst "niri.service")))))))))
