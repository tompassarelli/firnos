{ config, lib, ... }:

{
  options.myConfig.modules.printing.enable = lib.mkEnableOption "CUPS printing service with network discovery";

  config = lib.mkIf config.myConfig.modules.printing.enable {
    services.printing.enable = true;

    # Enable autodiscovery of network printers
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
