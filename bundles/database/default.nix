{ config, lib, ... }:
let cfg = config.myConfig.bundles.database;
in {
  options.myConfig.bundles.database = {
    enable = lib.mkEnableOption "database tools";
    dbeaver.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable DBeaver"; };
    sqlite.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable SQLite"; };
    postgresql.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable PostgreSQL"; };
    freetds.enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable FreeTDS"; };
  };

  config = lib.mkIf cfg.enable {
    myConfig.modules.dbeaver.enable = lib.mkDefault cfg.dbeaver.enable;
    myConfig.modules.sqlite.enable = lib.mkDefault cfg.sqlite.enable;
    myConfig.modules.postgresql.enable = lib.mkDefault cfg.postgresql.enable;
    myConfig.modules.freetds.enable = lib.mkDefault cfg.freetds.enable;
  };
}
