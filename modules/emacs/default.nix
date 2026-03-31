{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.emacs.enable = lib.mkEnableOption "GNU Emacs editor";

  config = lib.mkIf config.myConfig.modules.emacs.enable {
    environment.systemPackages = [ pkgs.emacs-pgtk ];
  };
}
