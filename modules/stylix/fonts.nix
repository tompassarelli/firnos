{ config, lib, ... }:

{
  config = lib.mkIf config.myConfig.modules.stylix.enable {
    fonts.fontconfig.enable = true;
  };
}
