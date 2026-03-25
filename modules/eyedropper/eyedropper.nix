{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.eyedropper.enable {
    environment.systemPackages = [ pkgs.eyedropper ];
  };
}
