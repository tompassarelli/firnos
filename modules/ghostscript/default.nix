{ lib, ... }:
{
  options.myConfig.modules.ghostscript.enable = lib.mkEnableOption "Ghostscript PostScript interpreter";
  imports = [ ./ghostscript.nix ];
}
