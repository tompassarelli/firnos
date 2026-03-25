{ lib, ... }:
{
  options.myConfig.media = {
    enable = lib.mkEnableOption "media applications and entertainment";
    discord.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Discord"; };
    zoom.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Zoom"; };
    spotify.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Spotify"; };
    youtube-music.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable YouTube Music"; };
    imv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable imv"; };
    mpv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable mpv"; };
    zathura.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Zathura"; };
    lutris.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Lutris"; };
    nautilus.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Nautilus"; };
    swaylock.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable swaylock"; };
    grim.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable grim"; };
    slurp.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable slurp"; };
    pavucontrol.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable pavucontrol"; };
  };

  imports = [
    ./media.nix
  ];
}
