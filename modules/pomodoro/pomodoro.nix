{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.pomodoro.enable {
    environment.systemPackages = [ pkgs.pomodoro-gtk ];
  };
}
