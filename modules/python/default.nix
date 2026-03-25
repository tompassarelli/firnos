{ lib, ... }:
{
  options.myConfig.modules.python.enable = lib.mkEnableOption "Python runtime with uv";
  imports = [ ./python.nix ];
}
