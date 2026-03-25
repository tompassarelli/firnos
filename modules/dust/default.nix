{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.dust = {
    enable = lib.mkEnableOption "Enable dust disk usage analyzer";
  };

  config = lib.mkIf config.myConfig.modules.dust.enable {
    environment.systemPackages = with pkgs; [ dust ];
  };
}
