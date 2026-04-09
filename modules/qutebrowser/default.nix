{ lib, ... }:
{
  options.myConfig.modules.qutebrowser = {
    enable = lib.mkEnableOption "Enable Qutebrowser";

    default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Qutebrowser as the default browser via MIME types";
    };
  };

  imports = [
    ./qutebrowser.nix
  ];
}
