{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.steam.enable {
    programs.steam = {
      enable = true;
      package = pkgs.unstable.steam;
    };
  };
}
