{ config, lib, ... }:
{
  options.myConfig.modules.polkit = {
    enable = lib.mkEnableOption "Polkit security configuration";
  };

  config = lib.mkIf config.myConfig.modules.polkit.enable {
    security.polkit.enable = true;
  };
}
