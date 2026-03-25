{ lib, ... }:
{
  options.myConfig.zathura.enable = lib.mkEnableOption "Zathura PDF viewer";
  imports = [ ./zathura.nix ];
}
