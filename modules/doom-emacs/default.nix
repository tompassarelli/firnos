{ lib, ... }:
{
  options.myConfig.doom-emacs = {
    enable = lib.mkEnableOption "Emacs with Doom Emacs (manual install)";
  };

  imports = [
    ./doom-emacs.nix
  ];
}
