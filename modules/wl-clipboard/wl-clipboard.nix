{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.wl-clipboard.enable {
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];
  };
}
