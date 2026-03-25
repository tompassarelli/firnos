{ lib, ... }:
{
  options.myConfig.modules.pomodoro.enable = lib.mkEnableOption "Pomodoro timer";
  imports = [ ./pomodoro.nix ];
}
