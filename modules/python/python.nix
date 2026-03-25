{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.python.enable {
    environment.systemPackages = [ pkgs.python3 ];
  };
}
