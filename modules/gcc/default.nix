{ lib, ... }:
{
  options.myConfig.modules.gcc.enable = lib.mkEnableOption "GNU C compiler";
  imports = [ ./gcc.nix ];
}
