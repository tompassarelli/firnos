{ lib, ... }:
{
  options.myConfig.tealdeer = {
    enable = lib.mkEnableOption "Enable tealdeer (tldr client)";
  };

  imports = [
    ./tealdeer.nix
  ];
}
