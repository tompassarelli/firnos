{ config, lib, ... }:
let cfg = config.myConfig.bundles.media;
in {
  options.myConfig.bundles.media = {
    enable = lib.mkEnableOption "media consumption and viewing";
    spotify.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Spotify"; };
    youtube-music.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable YouTube Music"; };
    imv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable imv"; };
    mpv.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable mpv"; };
    zathura.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable Zathura"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.spotify.enable = lib.mkDefault cfg.spotify.enable;
    myConfig.modules.youtube-music.enable = lib.mkDefault cfg.youtube-music.enable;
    myConfig.modules.imv.enable = lib.mkDefault cfg.imv.enable;
    myConfig.modules.mpv.enable = lib.mkDefault cfg.mpv.enable;
    myConfig.modules.zathura.enable = lib.mkDefault cfg.zathura.enable;
  };
}
