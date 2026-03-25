{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.pomodoro.enable {
    environment.systemPackages = [ pkgs.pomodoro-gtk ];
  };
}
