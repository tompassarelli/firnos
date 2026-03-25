{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.wl-clipboard.enable {
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];
  };
}
