{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.modules.stylix.enable {
    # Font configuration
    fonts.fontconfig.enable = true;
  };
}
