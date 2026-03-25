{ lib, ... }:
{
  options.myConfig.libnotify.enable = lib.mkEnableOption "libnotify notification client";
  imports = [ ./libnotify.nix ];
}
