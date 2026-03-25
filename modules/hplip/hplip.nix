{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.hplip.enable {
    services.printing.drivers = [ pkgs.hplip ];
  };
}
