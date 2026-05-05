{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.dust;
in
{
  options.myConfig.modules.dust.enable = lib.mkEnableOption "Enable dust disk usage analyzer";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ dust ];
  };
}
