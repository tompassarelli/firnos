{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.polkit.enable {
    security.polkit.enable = true;
  };
}
