{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.grim.enable {
    environment.systemPackages = [ pkgs.grim ];
  };
}
