{ lib, ... }:
{
  options.myConfig.pomodoro.enable = lib.mkEnableOption "Pomodoro timer";
  imports = [ ./pomodoro.nix ];
}
