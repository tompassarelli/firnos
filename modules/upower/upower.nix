{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.upower.enable {
    # Power monitoring
    services.upower.enable = true;
  };
}
