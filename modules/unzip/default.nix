{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.unzip.enable = lib.mkEnableOption "unzip archive tool";

  config = lib.mkIf config.myConfig.modules.unzip.enable {
    environment.systemPackages = [ pkgs.unzip ];
  };
}
