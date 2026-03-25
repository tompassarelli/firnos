{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.eza = {
    enable = lib.mkEnableOption "Enable eza (modern ls replacement)";
  };

  config = lib.mkIf config.myConfig.modules.eza.enable {
    environment.systemPackages = with pkgs; [ eza ];
  };
}
