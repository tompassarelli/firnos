{ lib, ... }:
{
  options.myConfig.godot.enable = lib.mkEnableOption "Godot game engine";
  imports = [ ./godot.nix ];
}
