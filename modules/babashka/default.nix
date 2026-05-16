{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.babashka;
in
{
  options.myConfig.modules.babashka.enable = lib.mkEnableOption "Babashka native Clojure scripting";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ babashka ];
  };
}
