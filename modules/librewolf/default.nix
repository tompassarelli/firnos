{ lib, ... }:
{
  options.myConfig.modules.librewolf = {
    enable = lib.mkEnableOption "Enable LibreWolf browser";

    default = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Set LibreWolf as the default browser via MIME types";
    };
  };

  imports = [
    ./librewolf.nix
  ];
}
