{ lib, ... }:
{
  options.myConfig.modules.swaylock.enable = lib.mkEnableOption "swaylock screen locker";
  imports = [ ./swaylock.nix ];
}
