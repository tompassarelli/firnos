{ lib, ... }:
{
  options.myConfig.bundles.doom-emacs = {
    enable = lib.mkEnableOption "Doom Emacs (emacs + build deps + tools)";
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

  imports = [ ./doom-emacs.nix ];
}
