{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.ghostscript.enable {
    environment.systemPackages = [ pkgs.ghostscript ];
  };
}
