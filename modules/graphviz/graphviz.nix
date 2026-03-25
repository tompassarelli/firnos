{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.graphviz.enable {
    environment.systemPackages = [ pkgs.graphviz ];
  };
}
