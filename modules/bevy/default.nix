{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.bevy;
  bevyLibs = with pkgs; [
    alsa-lib
    vulkan-loader
    vulkan-tools
    wayland
    libxkbcommon
    xorg.libX11
    xorg.libXcursor
    xorg.libXrandr
    xorg.libXi
    libudev-zero
  ];
in
{
  options.myConfig.modules.bevy.enable = lib.mkEnableOption "Bevy game engine development libraries";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = bevyLibs;
    programs.nix-ld.libraries = bevyLibs;
  };
}
