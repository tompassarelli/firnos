{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.doom.enable {
    # Enable the doom-emacs module
    myConfig.doom-emacs.enable = lib.mkDefault true;

    # Fonts required by Doom
    fonts.packages = with pkgs; [
      nerd-fonts.symbols-only
    ];

    # Tools recommended by doom doctor
    environment.systemPackages = with pkgs; [
      gnome-screenshot
      graphviz
      shellcheck
    ];
  };
}
