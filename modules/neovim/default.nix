{ lib, ... }:
{
  options.myConfig.neovim = {
    enable = lib.mkEnableOption "Neovim text editor";
  };

  imports = [
    ./neovim.nix
  ];
}
