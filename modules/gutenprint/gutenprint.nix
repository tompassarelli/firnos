{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.modules.gutenprint.enable {
    services.printing.drivers = [ pkgs.gutenprint ];
  };
}
