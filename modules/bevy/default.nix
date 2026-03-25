{ config, lib, pkgs, ... }:


let
  cfg = config.myConfig.modules.bevy;

  bevyLibs = with pkgs; [
    alsa-lib            # Audio
    vulkan-loader       # Graphics (Vulkan)
    vulkan-tools        # Vulkan debugging
    wayland             # Wayland window support
    libxkbcommon        # Keyboard input
    xorg.libX11         # X11 window support
    xorg.libXcursor     # X11 cursor support
    xorg.libXrandr      # X11 multi-monitor
    xorg.libXi          # X11 input devices
    libudev-zero        # Device detection (lightweight udev)
  ];
in
{
  options.myConfig.modules.bevy.enable = lib.mkEnableOption "Bevy game engine development libraries";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = bevyLibs;

    # Make Bevy libraries available via nix-ld (for running compiled binaries)
    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = bevyLibs;
  };
}
