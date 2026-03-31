{ config, lib, ... }:
let cfg = config.myConfig.bundles.doom-emacs;
in {
  options.myConfig.bundles.doom-emacs = {
    enable = lib.mkEnableOption "Doom Emacs (emacs + build deps + tools)";
    doom-emacs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Doom Emacs config"; };
    emacs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Emacs"; };
    nerd-fonts.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Nerd Fonts"; };
    ripgrep.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ripgrep"; };
    fd.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable fd"; };
    clang.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Clang (vterm)"; };
    cmake.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable CMake (vterm)"; };
    gnumake.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GNU Make (vterm)"; };
    gcc.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable GCC (vterm)"; };
    libtool.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable libtool (vterm)"; };
    sbcl.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable SBCL"; };
    gnome-screenshot.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable gnome-screenshot"; };
    graphviz.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Graphviz"; };
    shellcheck.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ShellCheck"; };
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
