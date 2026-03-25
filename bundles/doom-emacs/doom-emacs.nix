{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.doom-emacs;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.doom-emacs.enable = lib.mkDefault cfg.doom-emacs.enable;
    myConfig.modules.emacs.enable = lib.mkDefault cfg.emacs.enable;
    myConfig.modules.nerd-fonts.enable = lib.mkDefault cfg.nerd-fonts.enable;
    myConfig.modules.ripgrep.enable = lib.mkDefault cfg.ripgrep.enable;
    myConfig.modules.fd.enable = lib.mkDefault cfg.fd.enable;
    myConfig.modules.clang.enable = lib.mkDefault cfg.clang.enable;
    myConfig.modules.cmake.enable = lib.mkDefault cfg.cmake.enable;
    myConfig.modules.gnumake.enable = lib.mkDefault cfg.gnumake.enable;
    myConfig.modules.gcc.enable = lib.mkDefault cfg.gcc.enable;
    myConfig.modules.libtool.enable = lib.mkDefault cfg.libtool.enable;
    myConfig.modules.sbcl.enable = lib.mkDefault cfg.sbcl.enable;
    myConfig.modules.gnome-screenshot.enable = lib.mkDefault cfg.gnome-screenshot.enable;
    myConfig.modules.graphviz.enable = lib.mkDefault cfg.graphviz.enable;
    myConfig.modules.shellcheck.enable = lib.mkDefault cfg.shellcheck.enable;
  };
}
