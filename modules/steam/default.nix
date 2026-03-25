{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.steam.enable = lib.mkEnableOption "Steam gaming platform";

  config = lib.mkIf config.myConfig.modules.steam.enable {
    programs.steam = {
      enable = true;
      package = pkgs.unstable.steam;
    };
  };
}
