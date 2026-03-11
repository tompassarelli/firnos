{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.printing.enable {
    services.printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        hplip
      ];
    };

    # Enable autodiscovery of network printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
