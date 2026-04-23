{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.racket.enable = lib.mkEnableOption "Racket programming language";

  config = lib.mkIf config.myConfig.modules.racket.enable {
    environment.systemPackages = [ pkgs.racket-minimal ];
  };
}
