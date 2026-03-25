{ lib, ... }:
{
  options.myConfig.modules.eza = {
    enable = lib.mkEnableOption "Enable eza (modern ls replacement)";
  };

  imports = [
    ./eza.nix
  ];
}
