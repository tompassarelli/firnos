{ lib, ... }:
{
  options.myConfig.bevy.enable = lib.mkEnableOption "Bevy game engine development libraries";
  imports = [ ./bevy.nix ];
}
