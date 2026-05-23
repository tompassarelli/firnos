{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.obs-studio.enable = lib.mkEnableOption "OBS Studio screen recording";
  config = lib.mkIf config.myConfig.modules.obs-studio.enable {
    environment.systemPackages = with pkgs; [ obs-studio ];
  };
}
