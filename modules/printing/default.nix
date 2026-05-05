{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.printing;
in
{
  options.myConfig.modules.printing.enable = lib.mkEnableOption "CUPS printing service with network discovery";
  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
