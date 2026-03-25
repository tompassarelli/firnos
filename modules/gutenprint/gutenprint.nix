{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.gutenprint.enable {
    services.printing.drivers = [ pkgs.gutenprint ];
  };
}
