{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.hugo.enable {
    environment.systemPackages = [ pkgs.hugo ];
  };
}
