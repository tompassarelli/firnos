{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.wl-clipboard = {
    enable = lib.mkEnableOption "Wayland clipboard utilities";
  };

  config = lib.mkIf config.myConfig.modules.wl-clipboard.enable {
    environment.systemPackages = with pkgs; [
      wl-clipboard
    ];
  };
}
