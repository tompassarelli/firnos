{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.steam.enable {
    programs.steam = {
      enable = true;
      package = pkgs.unstable.steam;
    };
  };
}
