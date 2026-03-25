{ lib, ... }:
{
  options.myConfig.wf-recorder.enable = lib.mkEnableOption "Wayland screen recorder";
  imports = [ ./wf-recorder.nix ];
}
