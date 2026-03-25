{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.browsers;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.firefox.enable = lib.mkDefault cfg.firefox.enable;
    myConfig.modules.firefox.fennec.enable = lib.mkDefault cfg.firefox.fennec.enable;
    myConfig.modules.firefox.default = lib.mkDefault cfg.firefox.default;
    myConfig.modules.chrome.enable = lib.mkDefault cfg.chrome.enable;
    myConfig.modules.chrome.default = lib.mkDefault cfg.chrome.default;
    myConfig.modules.nyxt.enable = lib.mkDefault cfg.nyxt.enable;
    myConfig.modules.nyxt.default = lib.mkDefault cfg.nyxt.default;
    myConfig.modules.ladybird.enable = lib.mkDefault cfg.ladybird.enable;
  };
}
