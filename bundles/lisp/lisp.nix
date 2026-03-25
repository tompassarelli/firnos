{ config, lib, ... }:

let
  cfg = config.myConfig.lisp;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.doom-emacs.enable = lib.mkDefault cfg.doom-emacs.enable;
    myConfig.lem.enable = lib.mkDefault cfg.lem.enable;
    myConfig.sbcl.enable = lib.mkDefault cfg.sbcl.enable;
  };
}
