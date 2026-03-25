{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.grim.enable = lib.mkEnableOption "Grim screenshot tool";

  config = lib.mkIf config.myConfig.modules.grim.enable {
    environment.systemPackages = [ pkgs.grim ];
  };
}
