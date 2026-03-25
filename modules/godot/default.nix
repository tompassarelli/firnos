{ lib, ... }:
{
  options.myConfig.modules.godot.enable = lib.mkEnableOption "Godot game engine";
  imports = [ ./godot.nix ];
}
