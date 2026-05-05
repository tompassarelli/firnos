{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.browsers;
in
{
  options.myConfig.bundles.browsers.enable = lib.mkEnableOption "web browsers";
  options.myConfig.bundles.browsers.firefox.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable Firefox";
  };
  options.myConfig.bundles.browsers.firefox.palefox.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Palefox custom UI";
  };
  options.myConfig.bundles.browsers.firefox.default = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Set Firefox as default browser";
  };
  options.myConfig.bundles.browsers.chrome.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Chrome";
  };
  options.myConfig.bundles.browsers.chrome.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set Chrome as default browser";
  };
  options.myConfig.bundles.browsers.nyxt.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Nyxt";
  };
  options.myConfig.bundles.browsers.nyxt.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set Nyxt as default browser";
  };
  options.myConfig.bundles.browsers.ladybird.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Ladybird";
  };
  options.myConfig.bundles.browsers.qutebrowser.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Qutebrowser";
  };
  options.myConfig.bundles.browsers.qutebrowser.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set Qutebrowser as default browser";
  };
  options.myConfig.bundles.browsers.zen-browser.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable Zen Browser";
  };
  options.myConfig.bundles.browsers.zen-browser.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set Zen Browser as default browser";
  };
  options.myConfig.bundles.browsers.librewolf.enable = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Enable LibreWolf";
  };
  options.myConfig.bundles.browsers.librewolf.default = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set LibreWolf as default browser";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.firefox.enable = lib.mkDefault cfg.firefox.enable;
    myConfig.modules.firefox.palefox.enable = lib.mkDefault cfg.firefox.palefox.enable;
    myConfig.modules.firefox.default = lib.mkDefault cfg.firefox.default;
    myConfig.modules.chrome.enable = lib.mkDefault cfg.chrome.enable;
    myConfig.modules.chrome.default = lib.mkDefault cfg.chrome.default;
    myConfig.modules.nyxt.enable = lib.mkDefault cfg.nyxt.enable;
    myConfig.modules.nyxt.default = lib.mkDefault cfg.nyxt.default;
    myConfig.modules.ladybird.enable = lib.mkDefault cfg.ladybird.enable;
    myConfig.modules.qutebrowser.enable = lib.mkDefault cfg.qutebrowser.enable;
    myConfig.modules.qutebrowser.default = lib.mkDefault cfg.qutebrowser.default;
    myConfig.modules.zen-browser.enable = lib.mkDefault cfg.zen-browser.enable;
    myConfig.modules.zen-browser.default = lib.mkDefault cfg.zen-browser.default;
    myConfig.modules.librewolf.enable = lib.mkDefault cfg.librewolf.enable;
    myConfig.modules.librewolf.default = lib.mkDefault cfg.librewolf.default;
  };
}
