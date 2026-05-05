{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.btop;
in
{
  options.myConfig.modules.btop.enable = lib.mkEnableOption "Enable btop system monitor";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ btop ];
  };
}
