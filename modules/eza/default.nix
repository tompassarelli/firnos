{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.eza;
in
{
  options.myConfig.modules.eza.enable = lib.mkEnableOption "Enable eza (modern ls replacement)";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ eza ];
  };
}
