{ lib, ... }:
{
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
  };

  imports = [ ./browsers.nix ];
}
