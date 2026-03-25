{ lib, ... }:
{
  options.myConfig.modules.libnotify.enable = lib.mkEnableOption "libnotify notification client";
  imports = [ ./libnotify.nix ];
}
