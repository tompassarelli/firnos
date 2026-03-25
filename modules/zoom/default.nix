{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.zoom.enable = lib.mkEnableOption "Zoom video conferencing";

  config = lib.mkIf config.myConfig.modules.zoom.enable {
    environment.systemPackages = [ pkgs.zoom-us ];
  };
}
