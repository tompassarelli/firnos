{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.btop = {
    enable = lib.mkEnableOption "Enable btop system monitor";
  };

  config = lib.mkIf config.myConfig.modules.btop.enable {
    environment.systemPackages = with pkgs; [ btop ];
  };
}
