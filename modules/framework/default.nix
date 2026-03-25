{ lib, ... }:
{
  options.myConfig.modules.framework = {
    enable = lib.mkEnableOption "Framework Computer specific tools";
  };

  imports = [
    ./framework.nix
  ];
}
