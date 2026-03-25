{ lib, ... }:
{
  options.myConfig.sqlite.enable = lib.mkEnableOption "SQLite database";
  imports = [ ./sqlite.nix ];
}
