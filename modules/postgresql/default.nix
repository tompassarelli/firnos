{ lib, ... }:
{
  options.myConfig.postgresql = {
    enable = lib.mkEnableOption "PostgreSQL database server for local development";
  };

  imports = [
    ./postgresql.nix
  ];
}
