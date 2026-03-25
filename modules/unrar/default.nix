{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.unrar.enable = lib.mkEnableOption "unrar archive tool";

  config = lib.mkIf config.myConfig.modules.unrar.enable {
    environment.systemPackages = [ pkgs.unrar ];
  };
}
