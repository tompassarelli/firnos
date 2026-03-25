{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.godot.enable {
    environment.systemPackages = [ pkgs.unstable.godot_4 ];
  };
}
