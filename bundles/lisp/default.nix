{ lib, ... }:
{
  options.myConfig.lisp = {
    enable = lib.mkEnableOption "Common Lisp development";
    doom-emacs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable doom-emacs"; };
    lem.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable lem"; };
    sbcl.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable sbcl"; };
  };

  imports = [ ./lisp.nix ];
}
