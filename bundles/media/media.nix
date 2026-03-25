{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.media;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.discord.enable = lib.mkDefault cfg.discord.enable;
    myConfig.modules.zoom.enable = lib.mkDefault cfg.zoom.enable;
    myConfig.modules.spotify.enable = lib.mkDefault cfg.spotify.enable;
    myConfig.modules.youtube-music.enable = lib.mkDefault cfg.youtube-music.enable;
    myConfig.modules.imv.enable = lib.mkDefault cfg.imv.enable;
    myConfig.modules.mpv.enable = lib.mkDefault cfg.mpv.enable;
    myConfig.modules.zathura.enable = lib.mkDefault cfg.zathura.enable;
    myConfig.modules.lutris.enable = lib.mkDefault cfg.lutris.enable;
    myConfig.modules.nautilus.enable = lib.mkDefault cfg.nautilus.enable;
    myConfig.modules.swaylock.enable = lib.mkDefault cfg.swaylock.enable;
    myConfig.modules.grim.enable = lib.mkDefault cfg.grim.enable;
    myConfig.modules.slurp.enable = lib.mkDefault cfg.slurp.enable;
    myConfig.modules.pavucontrol.enable = lib.mkDefault cfg.pavucontrol.enable;
  };
}
