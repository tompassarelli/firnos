{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.printing;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.printing.enable = lib.mkDefault cfg.printing.enable;
    myConfig.modules.gutenprint.enable = lib.mkDefault cfg.gutenprint.enable;
    myConfig.modules.hplip.enable = lib.mkDefault cfg.hplip.enable;
  };
}
