{ lib, ... }:
{
  options.myConfig.firefox = {
    enable = lib.mkEnableOption "Enable Firefox browser";
    fennec.enable = lib.mkEnableOption "Enable Fennec (Firefox with custom UI styling)";

    default = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Set Firefox as the default browser via MIME types";
    };
  };

  imports = [
    ./firefox.nix
    ./fennec.nix
  ];
}
