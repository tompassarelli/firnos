{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.ripgrep.enable {
    environment.systemPackages = [ pkgs.ripgrep ];
  };
}
