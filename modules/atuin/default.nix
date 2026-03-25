{ lib, ... }:
{
  options.myConfig.modules.atuin = {
    enable = lib.mkEnableOption "atuin shell history sync";
  };

  imports = [
    ./atuin.nix
  ];
}
