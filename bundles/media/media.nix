{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.media;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.spotify.enable = lib.mkDefault cfg.spotify.enable;
    myConfig.modules.youtube-music.enable = lib.mkDefault cfg.youtube-music.enable;
    myConfig.modules.imv.enable = lib.mkDefault cfg.imv.enable;
    myConfig.modules.mpv.enable = lib.mkDefault cfg.mpv.enable;
    myConfig.modules.zathura.enable = lib.mkDefault cfg.zathura.enable;
  };
}
