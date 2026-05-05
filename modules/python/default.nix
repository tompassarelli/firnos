{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.python;
in
{
  options.myConfig.modules.python.enable = lib.mkEnableOption "Python runtime with uv";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ python3 ];
  };
}
