{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.zathura.enable {
    environment.systemPackages = [ pkgs.zathura ];
  };
}
