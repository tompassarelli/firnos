{ lib, ... }:
{
  options.myConfig.rustdesk.enable = lib.mkEnableOption "RustDesk remote desktop";
  imports = [ ./rustdesk.nix ];
}
