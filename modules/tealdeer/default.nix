{ lib, ... }:
{
  options.myConfig.modules.tealdeer = {
    enable = lib.mkEnableOption "Enable tealdeer (tldr client)";
  };

  imports = [
    ./tealdeer.nix
  ];
}
