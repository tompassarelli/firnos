{ lib, ... }:
{
  options.myConfig.bundles.browsers = {
    enable = lib.mkEnableOption "web browsers";
    firefox.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable firefox"; };
    chrome.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable chrome"; };
    nyxt.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable nyxt"; };
    ladybird.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ladybird"; };
  };

  imports = [ ./browsers.nix ];
}
