{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.gutenprint.enable = lib.mkEnableOption "Gutenprint printer drivers";

  config = lib.mkIf config.myConfig.modules.gutenprint.enable {
    services.printing.drivers = [ pkgs.gutenprint ];
  };
}
