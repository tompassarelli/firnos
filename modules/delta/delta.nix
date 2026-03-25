{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.delta.enable {
    environment.systemPackages = [ pkgs.delta ];
  };
}
