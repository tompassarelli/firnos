{ lib, ... }:
{
  options.myConfig.auto-upgrade = {
    enable = lib.mkEnableOption "Automatic system updates";
  };

  imports = [
    ./auto-upgrade.nix
  ];
}
