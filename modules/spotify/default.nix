{ lib, ... }:
{
  options.myConfig.spotify.enable = lib.mkEnableOption "Spotify TUI player";
  imports = [ ./spotify.nix ];
}
