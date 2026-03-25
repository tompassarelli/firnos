{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.godot.enable {
    environment.systemPackages = [ pkgs.unstable.godot_4 ];
  };
}
