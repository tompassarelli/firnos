{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.hplip.enable = lib.mkEnableOption "HP printer drivers";

  config = lib.mkIf config.myConfig.modules.hplip.enable {
    services.printing.drivers = [ pkgs.hplip ];
  };
}
