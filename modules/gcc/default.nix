{ lib, ... }:
{
  options.myConfig.gcc.enable = lib.mkEnableOption "GNU C compiler";
  imports = [ ./gcc.nix ];
}
