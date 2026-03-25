{ lib, ... }:
{
  options.myConfig.modules.git = {
    enable = lib.mkEnableOption "Git configuration";
  };

  imports = [
    ./git.nix
  ];
}
