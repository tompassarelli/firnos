{ lib, ... }:
{
  options.myConfig.modules.tree = {
    enable = lib.mkEnableOption "Enable tree file tree display utility";
  };

  imports = [
    ./tree.nix
  ];
}
