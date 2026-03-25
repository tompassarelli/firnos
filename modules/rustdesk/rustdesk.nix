{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.rustdesk.enable {
    environment.systemPackages = [ pkgs.rustdesk-flutter ];
  };
}
