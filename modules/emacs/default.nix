{ lib, ... }:
{
  options.myConfig.modules.emacs.enable = lib.mkEnableOption "GNU Emacs editor";
  imports = [ ./emacs.nix ];
}
