{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.wowup.enable {
    environment.systemPackages = [ pkgs.wowup-cf ];
  };
}
