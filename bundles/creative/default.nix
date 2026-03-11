{ lib, ... }:
{
  options.myConfig.creative = {
    enable = lib.mkEnableOption "creative tools and content creation";
  };

  imports = [
    ./creative.nix
  ];
}
