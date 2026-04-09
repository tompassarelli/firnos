{ config, lib, ... }:
let cfg = config.myConfig.bundles.browsers;
in {
  options.myConfig.bundles.browsers = {
    enable = lib.mkEnableOption "web browsers";
    firefox.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Firefox"; };
    firefox.fennec.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Fennec custom UI"; };
    firefox.default = lib.mkOption { type = lib.types.bool; default = true; description = "Set Firefox as default browser"; };
    chrome.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Chrome"; };
    chrome.default = lib.mkOption { type = lib.types.bool; default = false; description = "Set Chrome as default browser"; };
    nyxt.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Nyxt"; };
    nyxt.default = lib.mkOption { type = lib.types.bool; default = false; description = "Set Nyxt as default browser"; };
    ladybird.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Ladybird"; };
    qutebrowser.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Qutebrowser"; };
    qutebrowser.default = lib.mkOption { type = lib.types.bool; default = false; description = "Set Qutebrowser as default browser"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.firefox.enable = lib.mkDefault cfg.firefox.enable;
    myConfig.modules.firefox.fennec.enable = lib.mkDefault cfg.firefox.fennec.enable;
    myConfig.modules.firefox.default = lib.mkDefault cfg.firefox.default;
    myConfig.modules.chrome.enable = lib.mkDefault cfg.chrome.enable;
    myConfig.modules.chrome.default = lib.mkDefault cfg.chrome.default;
    myConfig.modules.nyxt.enable = lib.mkDefault cfg.nyxt.enable;
    myConfig.modules.nyxt.default = lib.mkDefault cfg.nyxt.default;
    myConfig.modules.ladybird.enable = lib.mkDefault cfg.ladybird.enable;
    myConfig.modules.qutebrowser.enable = lib.mkDefault cfg.qutebrowser.enable;
    myConfig.modules.qutebrowser.default = lib.mkDefault cfg.qutebrowser.default;
  };
}
