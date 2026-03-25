{ lib, ... }:
{
  options.myConfig.modules.procs = {
    enable = lib.mkEnableOption "Enable procs (modern ps replacement)";
  };

  imports = [
    ./procs.nix
  ];
}
