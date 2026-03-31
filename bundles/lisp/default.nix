{ config, lib, ... }:
let cfg = config.myConfig.bundles.lisp;
in {
  options.myConfig.bundles.lisp = {
    enable = lib.mkEnableOption "Lisp development";
    doom-emacs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Doom Emacs bundle"; };
    lem.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Lem"; };
    sbcl.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable SBCL"; };
    clojure.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Clojure"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.bundles.doom-emacs.enable = lib.mkDefault cfg.doom-emacs.enable;
    myConfig.modules.lem.enable = lib.mkDefault cfg.lem.enable;
    myConfig.modules.sbcl.enable = lib.mkDefault cfg.sbcl.enable;
    myConfig.modules.clojure.enable = lib.mkDefault cfg.clojure.enable;
  };
}
