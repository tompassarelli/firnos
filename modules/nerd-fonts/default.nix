{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.nerd-fonts.enable = lib.mkEnableOption "Nerd Fonts symbols";

  config = lib.mkIf config.myConfig.modules.nerd-fonts.enable {
    fonts.packages = [ pkgs.nerd-fonts.symbols-only ];
  };
}
