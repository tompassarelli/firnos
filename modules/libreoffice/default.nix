{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.libreoffice;
in
{
  options.myConfig.modules.libreoffice.enable = lib.mkEnableOption "Enable LibreOffice office suite";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ libreoffice-fresh ];
  };
}
