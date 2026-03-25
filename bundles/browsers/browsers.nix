{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.browsers;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.firefox.enable = lib.mkDefault cfg.firefox.enable;
    myConfig.modules.chrome.enable = lib.mkDefault cfg.chrome.enable;
    myConfig.modules.nyxt.enable = lib.mkDefault cfg.nyxt.enable;
    myConfig.modules.ladybird.enable = lib.mkDefault cfg.ladybird.enable;
  };
}
