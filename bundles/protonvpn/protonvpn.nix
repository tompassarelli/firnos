{ config, lib, ... }:

let
  cfg = config.myConfig.protonvpn;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.protonvpn-gui.enable = lib.mkDefault cfg.protonvpn-gui.enable;
    myConfig.protonvpn-cli.enable = lib.mkDefault cfg.protonvpn-cli.enable;
  };
}
