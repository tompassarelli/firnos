{ lib, ... }:
{
  options.myConfig.modules.chrome = {
    enable = lib.mkEnableOption "Enable Google Chrome browser";

    default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Chrome as the default browser via MIME types";
    };
  };

  imports = [
    ./chrome.nix
  ];
}
