{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.nerd-fonts.enable {
    fonts.packages = [ pkgs.nerd-fonts.symbols-only ];
  };
}
