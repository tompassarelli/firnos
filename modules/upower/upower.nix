{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.modules.upower.enable {
    # Power monitoring
    services.upower.enable = true;
  };
}
