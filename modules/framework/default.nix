{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.framework;
in
{
  options.myConfig.modules.framework = {
    enable = lib.mkEnableOption "Framework Computer specific tools";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.framework-tool ];

    # Disable suspend on lid close (sleep/wake issues)
    services.logind = {
      lidSwitch = "ignore";
      lidSwitchExternalPower = "ignore";
    };

    # MT7925e WiFi stability fixes
    # - disable_clc: Disables Country Location Code auto-detection (6GHz issues)
    # - disable_aspm: Disables PCI power management (prevents race conditions during roaming)
    boot.extraModprobeConfig = ''
      options mt7925_common disable_clc=1
      options mt7925e disable_aspm=1
    '';
  };
}
