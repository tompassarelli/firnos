{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.wl-gammarelay;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.wl-gammarelay.enable = lib.mkEnableOption "Wayland gamma/temperature control";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ wl-gammarelay-rs ];
    home-manager.users.${username} = { config, ... }: {
      xdg.configFile = {
        ${"wl-gammarelay/temperature-control"} = {
          source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/wl-gammarelay/temperature-control";
        };
      };
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
