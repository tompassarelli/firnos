{ lib, ... }:
{
  options.myConfig.modules.graphviz.enable = lib.mkEnableOption "Graphviz graph visualization";
  imports = [ ./graphviz.nix ];
}
