{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.gimp.enable {
    environment.systemPackages = [ pkgs.gimp ];
  };
}
