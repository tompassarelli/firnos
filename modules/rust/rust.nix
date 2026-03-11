{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.rust;

  # Bevy game engine requires native system libraries for graphics, audio, and windowing
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
  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      environment.systemPackages = with pkgs; [
        unstable.rustc       # rust compiler (from unstable for latest version)
        unstable.cargo       # rust package manager (from unstable)
        unstable.rust-analyzer  # rust language server (from unstable)
        unstable.clippy      # rust linter (from unstable)
        unstable.rustfmt     # rust formatter (from unstable)
        pkg-config           # helps find system libraries during compilation
        gcc                  # C compiler (needed for building Rust dependencies)
      ] ++ lib.optionals cfg.bevy bevyLibs;
    }

    # Make Bevy libraries available via nix-ld (for running compiled binaries)
    (lib.mkIf cfg.bevy {
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = bevyLibs;
    })
  ]);
}
