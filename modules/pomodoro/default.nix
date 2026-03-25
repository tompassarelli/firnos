{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.pomodoro.enable = lib.mkEnableOption "Pomodoro timer";

  config = lib.mkIf config.myConfig.modules.pomodoro.enable {
    environment.systemPackages = [ pkgs.pomodoro-gtk ];
  };
}
