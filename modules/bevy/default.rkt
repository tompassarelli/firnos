#lang nisp

(module-file modules bevy
  (desc "Bevy game engine development libraries")
  (lets ([bevyLibs (with-pkgs
                     alsa-lib
                     vulkan-loader
                     vulkan-tools
                     wayland
                     libxkbcommon
                     xorg.libX11
                     xorg.libXcursor
                     xorg.libXrandr
                     xorg.libXi
                     libudev-zero)]))
  (config-body
    (set environment.systemPackages 'bevyLibs)
    ;; Make Bevy libraries available via nix-ld
    (set programs.nix-ld.libraries 'bevyLibs)))
