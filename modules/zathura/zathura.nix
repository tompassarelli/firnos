{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.zathura.enable {
    environment.systemPackages = [ pkgs.zathura ];
  };
}
