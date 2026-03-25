{ lib, ... }:
{
  options.myConfig.ghostscript.enable = lib.mkEnableOption "Ghostscript PostScript interpreter";
  imports = [ ./ghostscript.nix ];
}
