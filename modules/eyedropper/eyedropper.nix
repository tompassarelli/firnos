{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.eyedropper.enable {
    environment.systemPackages = [ pkgs.eyedropper ];
  };
}
