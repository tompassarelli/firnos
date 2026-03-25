{ lib, ... }:
{
  options.myConfig.modules.zathura.enable = lib.mkEnableOption "Zathura PDF viewer";
  imports = [ ./zathura.nix ];
}
