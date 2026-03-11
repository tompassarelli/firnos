{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.protonvpn;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      protonvpn-gui
      protonvpn-cli
    ];
  };
}
