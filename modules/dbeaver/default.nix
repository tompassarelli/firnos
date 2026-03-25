{ lib, ... }:
{
  options.myConfig.dbeaver.enable = lib.mkEnableOption "DBeaver database GUI";
  imports = [ ./dbeaver.nix ];
}
