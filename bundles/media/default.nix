{ lib, ... }:
{
  options.myConfig.media = {
    enable = lib.mkEnableOption "media applications and entertainment";
  };

  imports = [
    ./media.nix
  ];
}