{ lib, ... }:
{
  options.myConfig.modules.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL database server for local development";
  };

  imports = [
    ./postgresql.nix
  ];
}
