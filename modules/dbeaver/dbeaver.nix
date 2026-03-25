{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.dbeaver.enable {
    environment.systemPackages = [ pkgs.dbeaver-bin ];
  };
}
