{ lib, ... }:
{
  options.myConfig.doom = {
    enable = lib.mkEnableOption "Doom Emacs bundle (emacs + fonts + tools)";
  };

  imports = [
    ./doom.nix
  ];
}
