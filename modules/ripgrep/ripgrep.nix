{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.ripgrep.enable {
    environment.systemPackages = [ pkgs.ripgrep ];
  };
}
