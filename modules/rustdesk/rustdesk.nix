{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.rustdesk.enable {
    environment.systemPackages = [ pkgs.rustdesk-flutter ];
  };
}
