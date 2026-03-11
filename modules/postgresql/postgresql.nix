{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.postgresql;
  # PostgreSQL with extensions
  postgresWithExtensions = pkgs.postgresql_17.withPackages (ps: [
    ps.pg_uuidv7
  ]);
in
{
  config = lib.mkIf cfg.enable {
    # PostgreSQL service
    services.postgresql = {
      enable = true;
      package = postgresWithExtensions;

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
    environment.systemPackages = with pkgs; [
      postgresql_17      # includes psql client
    ];
  };
}
