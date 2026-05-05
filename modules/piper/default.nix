{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.piper;
in
{
  options.myConfig.modules.piper.enable = lib.mkEnableOption "gaming mouse configuration (Piper + ratbagd)";
  config = lib.mkIf cfg.enable {
    services.ratbagd.enable = true;
    environment.systemPackages = with pkgs; [ piper ];
  };
}
