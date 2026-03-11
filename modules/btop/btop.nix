{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.btop.enable {
    environment.systemPackages = with pkgs; [ btop ];
  };
}
