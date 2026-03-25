{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.spotify.enable = lib.mkEnableOption "Spotify TUI player";

  config = lib.mkIf config.myConfig.modules.spotify.enable {
    environment.systemPackages = [ pkgs.spotify-player ];
  };
}
