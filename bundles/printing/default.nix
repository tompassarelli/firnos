{ config, lib, ... }:
let cfg = config.myConfig.bundles.printing;
in {
  options.myConfig.bundles.printing = {
    enable = lib.mkEnableOption "printing support (CUPS + drivers)";
    printing.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable CUPS printing"; };
    gutenprint.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Gutenprint"; };
    hplip.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable HP drivers"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.printing.enable = lib.mkDefault cfg.printing.enable;
    myConfig.modules.gutenprint.enable = lib.mkDefault cfg.gutenprint.enable;
    myConfig.modules.hplip.enable = lib.mkDefault cfg.hplip.enable;
  };
}
