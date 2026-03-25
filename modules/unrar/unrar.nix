{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.unrar.enable {
    environment.systemPackages = [ pkgs.unrar ];
  };
}
