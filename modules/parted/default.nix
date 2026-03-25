{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.parted.enable = lib.mkEnableOption "disk partitioning tool";

  config = lib.mkIf config.myConfig.modules.parted.enable {
    environment.systemPackages = [ pkgs.parted ];
  };
}
