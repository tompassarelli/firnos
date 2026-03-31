{ config, lib, pkgs, ... }:
let
  cfg = config.myConfig.modules.postgresql;
  # PostgreSQL 18 from unstable — uuidv7() is built-in, no extension needed
  postgresPackage = pkgs.unstable.postgresql_18;
in
{
  options.myConfig.modules.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL database server for local development";
  };

  config = lib.mkIf cfg.enable {
    # PostgreSQL service
    services.postgresql = {
      enable = true;
      package = postgresPackage;

      # Trust local connections (dev only - no password needed)
      authentication = pkgs.lib.mkOverride 10 ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
      '';

      # Create default dev databases
      ensureDatabases = [ "postgres" ];

      # Ensure postgres user exists with superuser (for dev convenience)
      ensureUsers = [
        {
          name = "postgres";
          ensureClauses.superuser = true;
        }
      ];
    };

    # Add psql client and other useful tools to system packages
    environment.systemPackages = [ postgresPackage ];
  };
}
