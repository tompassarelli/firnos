{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.printing;
in
{
  config = lib.mkIf cfg.enable {
    services.printing.enable = true;

    # Enable autodiscovery of network printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    myConfig.modules.gutenprint.enable = lib.mkDefault cfg.gutenprint.enable;
    myConfig.modules.hplip.enable = lib.mkDefault cfg.hplip.enable;
  };
}
