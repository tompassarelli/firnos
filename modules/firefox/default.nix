{ lib, ... }:
{
  options.myConfig.modules.firefox = {
    enable = lib.mkEnableOption "Enable Firefox browser";
    palefox.enable = lib.mkEnableOption "Enable Palefox (Firefox with custom UI styling)";

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Firefox as the default browser via MIME types";
    };
  };

  imports = [
    ./firefox.nix
    ./palefox.nix
  ];
}
