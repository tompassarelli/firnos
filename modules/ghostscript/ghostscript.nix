{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.ghostscript.enable {
    environment.systemPackages = [ pkgs.ghostscript ];
  };
}
