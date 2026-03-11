{ lib, ... }:
{
  options.myConfig.development = {
    enable = lib.mkEnableOption "development tools and programming utilities";
  };

  imports = [
    ./development.nix
  ];
}
