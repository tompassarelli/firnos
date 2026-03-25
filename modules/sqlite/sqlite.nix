{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.sqlite.enable {
    environment.systemPackages = [ pkgs.sqlite ];
  };
}
