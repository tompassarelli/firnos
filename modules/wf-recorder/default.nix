{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.wf-recorder.enable = lib.mkEnableOption "Wayland screen recorder";

  config = lib.mkIf config.myConfig.modules.wf-recorder.enable {
    environment.systemPackages = [ pkgs.wf-recorder ];
  };
}
