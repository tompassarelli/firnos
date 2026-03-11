{ lib, ... }:
{
  options.myConfig.git = {
    enable = lib.mkEnableOption "Git configuration";
  };

  imports = [
    ./git.nix
  ];
}
