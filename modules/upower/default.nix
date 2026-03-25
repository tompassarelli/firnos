{ config, lib, ... }:
{
  options.myConfig.modules.upower = {
    enable = lib.mkEnableOption "UPower power management";
  };

  config = lib.mkIf config.myConfig.modules.upower.enable {
    # Power monitoring
    services.upower.enable = true;
  };
}
