{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.sbcl.enable = lib.mkEnableOption "Steel Bank Common Lisp compiler";

  config = lib.mkIf config.myConfig.modules.sbcl.enable {
    environment.systemPackages = [ pkgs.sbcl ];
  };
}
