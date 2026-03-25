{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.libnotify.enable = lib.mkEnableOption "libnotify notification client";

  config = lib.mkIf config.myConfig.modules.libnotify.enable {
    environment.systemPackages = [ pkgs.libnotify ];
  };
}
