{ lib, ... }:
{
  options.myConfig.modules.pandoc.enable = lib.mkEnableOption "Pandoc document converter";
  imports = [ ./pandoc.nix ];
}
