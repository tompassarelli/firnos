{ lib, ... }:
{
  options.myConfig.modules.dust = {
    enable = lib.mkEnableOption "Enable dust disk usage analyzer";
  };

  imports = [
    ./dust.nix
  ];
}
