{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.upower.enable = lib.mkEnableOption "UPower power management";
  config = lib.mkIf config.myConfig.modules.upower.enable {
    services.upower.enable = true;
  };
}
