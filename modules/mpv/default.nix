{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.mpv.enable = lib.mkEnableOption "mpv media player";

  config = lib.mkIf config.myConfig.modules.mpv.enable {
    environment.systemPackages = [ pkgs.mpv ];
  };
}
