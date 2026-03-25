{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.wowup.enable {
    environment.systemPackages = [ pkgs.wowup-cf ];
  };
}
