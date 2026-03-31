{ lib, ... }:
{
  options.myConfig.bundles.lisp = {
    enable = lib.mkEnableOption "Lisp development";
    doom-emacs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable doom-emacs"; };
    lem.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable lem"; };
    sbcl.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable sbcl"; };
    clojure.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Clojure"; };
  };

  imports = [ ./lisp.nix ];
}
