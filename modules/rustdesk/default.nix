{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.rustdesk.enable = lib.mkEnableOption "RustDesk remote desktop";

  config = lib.mkIf config.myConfig.modules.rustdesk.enable {
    environment.systemPackages = [ pkgs.rustdesk-flutter ];
  };
}
