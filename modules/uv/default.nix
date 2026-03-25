{ lib, ... }:
{
  options.myConfig.modules.uv.enable = lib.mkEnableOption "uv Python package manager";
  imports = [ ./uv.nix ];
}
