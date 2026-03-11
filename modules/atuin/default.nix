{ lib, ... }:
{
  options.myConfig.atuin = {
    enable = lib.mkEnableOption "atuin shell history sync";
  };

  imports = [
    ./atuin.nix
  ];
}
