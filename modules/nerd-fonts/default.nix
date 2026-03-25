{ lib, ... }:
{
  options.myConfig.nerd-fonts.enable = lib.mkEnableOption "Nerd Fonts symbols";
  imports = [ ./nerd-fonts.nix ];
}
