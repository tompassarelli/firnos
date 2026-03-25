{ lib, ... }:
{
  options.myConfig.sbcl.enable = lib.mkEnableOption "Steel Bank Common Lisp compiler";
  imports = [ ./sbcl.nix ];
}
