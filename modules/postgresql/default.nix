{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.postgresql;
  postgresPackage = pkgs.unstable.postgresql_18;
in
{
  options.myConfig.modules.postgresql.enable = lib.mkEnableOption "PostgreSQL database server for local development";
  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = postgresPackage;
      authentication = pkgs.lib.mkOverride 10 ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
      '';
      ensureDatabases = [ "postgres" ];
      ensureUsers = [
        {
          name = "postgres";
          ensureClauses.superuser = true;
        }
      ];
    };
    environment.systemPackages = [ postgresPackage ];
  };
}
