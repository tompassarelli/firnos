{ lib, ... }:
{
  options.myConfig.modules.sbcl.enable = lib.mkEnableOption "Steel Bank Common Lisp compiler";
  imports = [ ./sbcl.nix ];
}
