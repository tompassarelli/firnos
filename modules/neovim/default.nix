{ lib, ... }:
{
  options.myConfig.modules.neovim = {
    enable = lib.mkEnableOption "Neovim text editor";
  };

  imports = [
    ./neovim.nix
  ];
}
