{ lib, ... }:
{
  options.myConfig.python.enable = lib.mkEnableOption "Python runtime with uv";
  imports = [ ./python.nix ];
}
