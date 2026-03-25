{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.modules.polkit.enable {
    security.polkit.enable = true;
  };
}
