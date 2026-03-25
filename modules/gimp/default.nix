{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.gimp.enable = lib.mkEnableOption "GIMP image editor";

  config = lib.mkIf config.myConfig.modules.gimp.enable {
    environment.systemPackages = [ pkgs.gimp ];
  };
}
