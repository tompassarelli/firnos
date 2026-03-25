{ lib, ... }:
{
  options.myConfig.pandoc.enable = lib.mkEnableOption "Pandoc document converter";
  imports = [ ./pandoc.nix ];
}
