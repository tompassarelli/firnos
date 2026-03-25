{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.lisp;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.bundles.doom-emacs.enable = lib.mkDefault cfg.doom-emacs.enable;
    myConfig.modules.lem.enable = lib.mkDefault cfg.lem.enable;
    myConfig.modules.sbcl.enable = lib.mkDefault cfg.sbcl.enable;
  };
}
