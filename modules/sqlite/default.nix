{ lib, ... }:
{
  options.myConfig.modules.sqlite.enable = lib.mkEnableOption "SQLite database";
  imports = [ ./sqlite.nix ];
}
