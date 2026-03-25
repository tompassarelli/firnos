{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.godot.enable = lib.mkEnableOption "Godot game engine";

  config = lib.mkIf config.myConfig.modules.godot.enable {
    environment.systemPackages = [ pkgs.unstable.godot_4 ];
  };
}
