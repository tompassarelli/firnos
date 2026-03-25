{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.parted.enable {
    environment.systemPackages = [ pkgs.parted ];
  };
}
