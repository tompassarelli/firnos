{ lib, ... }:
{
  options.myConfig.uv.enable = lib.mkEnableOption "uv Python package manager";
  imports = [ ./uv.nix ];
}
