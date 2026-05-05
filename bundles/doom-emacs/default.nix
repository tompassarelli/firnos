{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.doom-emacs;
in
{
  options.myConfig.bundles.doom-emacs.enable = lib.mkEnableOption "Doom Emacs (emacs + build deps + tools)";
  options.myConfig.bundles.doom-emacs.doom-emacs.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable doom-emacs";
  };
  options.myConfig.bundles.doom-emacs.emacs.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable emacs";
  };
  options.myConfig.bundles.doom-emacs.nerd-fonts.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable nerd-fonts";
  };
  options.myConfig.bundles.doom-emacs.ripgrep.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable ripgrep";
  };
  options.myConfig.bundles.doom-emacs.fd.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable fd";
  };
  options.myConfig.bundles.doom-emacs.clang.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable clang";
  };
  options.myConfig.bundles.doom-emacs.cmake.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable cmake";
  };
  options.myConfig.bundles.doom-emacs.gnumake.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable gnumake";
  };
  options.myConfig.bundles.doom-emacs.gcc.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable gcc";
  };
  options.myConfig.bundles.doom-emacs.libtool.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable libtool";
  };
  options.myConfig.bundles.doom-emacs.sbcl.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable sbcl";
  };
  options.myConfig.bundles.doom-emacs.gnome-screenshot.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable gnome-screenshot";
  };
  options.myConfig.bundles.doom-emacs.graphviz.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable graphviz";
  };
  options.myConfig.bundles.doom-emacs.shellcheck.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable shellcheck";
  };
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
