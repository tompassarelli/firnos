{ lib, ... }:
{
  options.myConfig.modules.dbeaver.enable = lib.mkEnableOption "DBeaver database GUI";
  imports = [ ./dbeaver.nix ];
}
