{ lib, ... }:
{
  options.myConfig.modules.rustdesk.enable = lib.mkEnableOption "RustDesk remote desktop";
  imports = [ ./rustdesk.nix ];
}
