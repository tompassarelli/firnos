{ lib, ... }:
{
  options.myConfig.modules.spotify.enable = lib.mkEnableOption "Spotify TUI player";
  imports = [ ./spotify.nix ];
}
