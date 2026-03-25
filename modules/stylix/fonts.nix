{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.stylix.enable {
    # Font configuration
    fonts.fontconfig.enable = true;
  };
}
