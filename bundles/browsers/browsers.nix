{ config, lib, ... }:

let
  cfg = config.myConfig.browsers;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.firefox.enable = lib.mkDefault cfg.firefox.enable;
    myConfig.chrome.enable = lib.mkDefault cfg.chrome.enable;
    myConfig.nyxt.enable = lib.mkDefault cfg.nyxt.enable;
    myConfig.ladybird.enable = lib.mkDefault cfg.ladybird.enable;
  };
}
