{ config, lib, ... }:

let
  cfg = config.myConfig.media;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.discord.enable = lib.mkDefault cfg.discord.enable;
    myConfig.zoom.enable = lib.mkDefault cfg.zoom.enable;
    myConfig.spotify.enable = lib.mkDefault cfg.spotify.enable;
    myConfig.youtube-music.enable = lib.mkDefault cfg.youtube-music.enable;
    myConfig.imv.enable = lib.mkDefault cfg.imv.enable;
    myConfig.mpv.enable = lib.mkDefault cfg.mpv.enable;
    myConfig.zathura.enable = lib.mkDefault cfg.zathura.enable;
    myConfig.lutris.enable = lib.mkDefault cfg.lutris.enable;
    myConfig.nautilus.enable = lib.mkDefault cfg.nautilus.enable;
    myConfig.swaylock.enable = lib.mkDefault cfg.swaylock.enable;
    myConfig.grim.enable = lib.mkDefault cfg.grim.enable;
    myConfig.slurp.enable = lib.mkDefault cfg.slurp.enable;
    myConfig.pavucontrol.enable = lib.mkDefault cfg.pavucontrol.enable;
  };
}
