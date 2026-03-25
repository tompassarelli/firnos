{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.graphviz.enable = lib.mkEnableOption "Graphviz graph visualization";

  config = lib.mkIf config.myConfig.modules.graphviz.enable {
    environment.systemPackages = [ pkgs.graphviz ];
  };
}
