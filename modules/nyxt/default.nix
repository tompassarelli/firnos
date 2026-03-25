{ lib, ... }:
{
  options.myConfig.modules.nyxt = {
    enable = lib.mkEnableOption "Enable Nyxt browser";

    default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set Nyxt as the default browser via MIME types";
    };
  };

  imports = [
    ./nyxt.nix
  ];
}
