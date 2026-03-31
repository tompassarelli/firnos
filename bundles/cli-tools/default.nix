{ lib, ... }:
{
  options.myConfig.bundles.cli-tools = {
    enable = lib.mkEnableOption "modern CLI tools";
    yazi.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable yazi"; };
    tree.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable tree"; };
    dust.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable dust"; };
    eza.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable eza"; };
    procs.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable procs"; };
    tealdeer.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable tealdeer"; };
    fastfetch.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable fastfetch"; };
    btop.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable btop"; };
    unrar.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable unrar"; };
    curl.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable curl"; };
    wget.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable wget"; };
    unzip.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable unzip"; };
    imagemagick.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable ImageMagick"; };
    ghostscript.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Ghostscript"; };
  };

  imports = [ ./cli-tools.nix ];
}
