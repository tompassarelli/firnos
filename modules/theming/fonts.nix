{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.theming.enable {
    # Font configuration
    fonts.fontconfig.enable = true;
  };
}
