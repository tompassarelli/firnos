{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myConfig.quickshell;
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf cfg.enable {
    # SYSTEM: Install quickshell
    environment.systemPackages = [
      inputs.quickshell.packages.${pkgs.system}.default
    ];

    # HOME-MANAGER: Dotfiles and services
    home-manager.users.${username} = { config, ... }: {
      # Dotfiles: QML config (live-edit symlink)
      xdg.configFile."quickshell/shell.qml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/quickshell/shell.qml";

      xdg.configFile."quickshell/Bar.qml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/quickshell/Bar.qml";

      xdg.configFile."quickshell/NiriListener.qml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/quickshell/NiriListener.qml";

      xdg.configFile."quickshell/BarState.qml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/quickshell/BarState.qml";

      # Systemd service: Quickshell daemon
      systemd.user.services.quickshell = {
        Unit = {
          Description = "Quickshell widget framework";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${inputs.quickshell.packages.${pkgs.system}.default}/bin/qs";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "niri.service" ];
        };
      };
    };
  };
}
