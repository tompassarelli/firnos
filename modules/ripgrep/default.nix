{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.ripgrep.enable = lib.mkEnableOption "ripgrep search tool";

  config = lib.mkIf config.myConfig.modules.ripgrep.enable {
    environment.systemPackages = [ pkgs.ripgrep ];
  };
}
