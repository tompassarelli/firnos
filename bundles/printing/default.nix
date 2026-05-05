{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.printing;
in
{
  options.myConfig.bundles.printing.enable = lib.mkEnableOption "printing support (CUPS + drivers)";
  options.myConfig.bundles.printing.printing.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable printing";
  };
  options.myConfig.bundles.printing.gutenprint.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable gutenprint";
  };
  options.myConfig.bundles.printing.hplip.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable hplip";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.printing.enable = lib.mkDefault cfg.printing.enable;
    myConfig.modules.gutenprint.enable = lib.mkDefault cfg.gutenprint.enable;
    myConfig.modules.hplip.enable = lib.mkDefault cfg.hplip.enable;
  };
}
