{ config, lib, ... }:
{
  config = lib.mkIf config.myConfig.modules.stylix.enable {
    # Font configuration
    fonts.fontconfig = {
      enable = true;
      localConf = ''
        <match target="font">
          <test name="family" compare="contains">
            <string>Maple Mono</string>
          </test>
          <edit name="fontfeatures" mode="append">
            <string>cv01 on</string>
          </edit>
        </match>
      '';
    };
  };
}
