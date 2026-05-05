{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.bundles.media;
in
{
  options.myConfig.bundles.media.enable = lib.mkEnableOption "media consumption and viewing";
  options.myConfig.bundles.media.spotify.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable spotify";
  };
  options.myConfig.bundles.media.youtube-music.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable youtube-music";
  };
  options.myConfig.bundles.media.imv.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable imv";
  };
  options.myConfig.bundles.media.mpv.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable mpv";
  };
  options.myConfig.bundles.media.zathura.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable zathura";
  };
  config = lib.mkIf cfg.enable {
    myConfig.modules.spotify.enable = lib.mkDefault cfg.spotify.enable;
    myConfig.modules.youtube-music.enable = lib.mkDefault cfg.youtube-music.enable;
    myConfig.modules.imv.enable = lib.mkDefault cfg.imv.enable;
    myConfig.modules.mpv.enable = lib.mkDefault cfg.mpv.enable;
    myConfig.modules.zathura.enable = lib.mkDefault cfg.zathura.enable;
  };
}
