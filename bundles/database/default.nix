{ lib, ... }:
{
  options.myConfig.bundles.database = {
    enable = lib.mkEnableOption "database tools";
    dbeaver.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable DBeaver"; };
    sqlite.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable SQLite"; };
    postgresql.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable PostgreSQL"; };
  };

  imports = [ ./database.nix ];
}
