{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.gh.enable = lib.mkEnableOption "GitHub CLI";

  config = lib.mkIf config.myConfig.modules.gh.enable {
    environment.systemPackages = [ pkgs.gh ];
  };
}
