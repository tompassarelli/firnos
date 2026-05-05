{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.clojure;
in
{
  options.myConfig.modules.clojure.enable = lib.mkEnableOption "Clojure development (JDK, clj CLI, LSP, linting, formatting)";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs.unstable; [
      jdk21
      clojure
      clj-kondo
      clojure-lsp
      neil
      jet
      cljfmt
    ];
  };
}
