{ lib, ... }:
{
  options.myConfig.graphviz.enable = lib.mkEnableOption "Graphviz graph visualization";
  imports = [ ./graphviz.nix ];
}
