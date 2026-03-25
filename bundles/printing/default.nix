{ lib, ... }:
{
  options.myConfig.bundles.printing = {
    enable = lib.mkEnableOption "printing support (CUPS + drivers)";
    gutenprint.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Gutenprint drivers"; };
    hplip.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable HP drivers"; };
  };

  imports = [ ./printing.nix ];
}
