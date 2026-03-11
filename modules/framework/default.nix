{ lib, ... }:
{
  options.myConfig.framework = {
    enable = lib.mkEnableOption "Framework Computer specific tools";
  };

  imports = [
    ./framework.nix
  ];
}
