{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.btop.enable {
    environment.systemPackages = with pkgs; [ btop ];
  };
}
