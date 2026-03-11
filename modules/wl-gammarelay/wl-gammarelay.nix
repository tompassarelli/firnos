{ config, lib, pkgs, ... }:
let
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf config.myConfig.wl-gammarelay.enable {
    environment.systemPackages = with pkgs; [
      wl-gammarelay-rs
    ];

    home-manager.users.${username} = { config, ... }: {
      # Temperature control script
      xdg.configFile."wl-gammarelay/temperature-control".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/wl-gammarelay/temperature-control";

      # wl-gammarelay systemd service
      systemd.user.services.wl-gammarelay = {
        Unit = {
          Description = "Gamma control for Wayland";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.wl-gammarelay-rs}/bin/wl-gammarelay-rs";
          Restart = "on-failure";
          Type = "dbus";
          BusName = "rs.wl-gammarelay";
        };
        Install = {
          WantedBy = [ "niri.service" ];
        };
      };
    };
  };
}
