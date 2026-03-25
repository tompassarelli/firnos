{ lib, ... }:
{
  options.myConfig.youtube-music.enable = lib.mkEnableOption "YouTube Music client";
  imports = [ ./youtube-music.nix ];
}
