{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.unzip.enable {
    environment.systemPackages = [ pkgs.unzip ];
  };
}
