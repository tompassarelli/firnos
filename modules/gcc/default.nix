{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.gcc.enable = lib.mkEnableOption "GNU C compiler";

  config = lib.mkIf config.myConfig.modules.gcc.enable {
    environment.systemPackages = [ pkgs.gcc ];
  };
}
