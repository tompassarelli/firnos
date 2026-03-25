{ config, lib, ... }:

let
  cfg = config.myConfig.gaming;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.steam.enable = lib.mkDefault cfg.steam.enable;
    myConfig.lutris.enable = lib.mkDefault cfg.lutris.enable;
    myConfig.wowup.enable = lib.mkDefault cfg.wowup.enable;
  };
}
