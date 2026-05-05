{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.framework;
in
{
  options.myConfig.modules.framework.enable = lib.mkEnableOption "Framework Computer specific tools";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ framework-tool ];
    services.logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
    boot.extraModprobeConfig = ''
      options mt7925_common disable_clc=1
      options mt7925e disable_aspm=1
    '';
  };
}
