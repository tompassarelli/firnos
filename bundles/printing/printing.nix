{ config, lib, ... }:

let
  cfg = config.myConfig.printing;
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

    myConfig.gutenprint.enable = lib.mkDefault cfg.gutenprint.enable;
    myConfig.hplip.enable = lib.mkDefault cfg.hplip.enable;
  };
}
