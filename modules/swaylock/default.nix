{ lib, ... }:
{
  options.myConfig.swaylock.enable = lib.mkEnableOption "swaylock screen locker";
  imports = [ ./swaylock.nix ];
}
