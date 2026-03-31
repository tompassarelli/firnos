{ lib, ... }:
{
  options.myConfig.bundles.media = {
    enable = lib.mkEnableOption "media consumption and viewing";
    spotify.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Spotify"; };
    youtube-music.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable YouTube Music"; };
    imv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable imv"; };
    mpv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable mpv"; };
    zathura.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Zathura"; };
  };

  imports = [
    ./media.nix
  ];
}
