{ lib, ... }:
{
  options.myConfig.emacs.enable = lib.mkEnableOption "GNU Emacs editor";
  imports = [ ./emacs.nix ];
}
