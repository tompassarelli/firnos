{ lib, ... }:
{
  options.myConfig.eza = {
    enable = lib.mkEnableOption "Enable eza (modern ls replacement)";
  };

  imports = [
    ./eza.nix
  ];
}
