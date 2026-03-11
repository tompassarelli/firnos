{ lib, ... }:
{
  options.myConfig.rust = {
    enable = lib.mkEnableOption "Rust development toolchain";

    bevy = lib.mkEnableOption "Bevy game engine development libraries";
  };

  imports = [
    ./rust.nix
  ];
}