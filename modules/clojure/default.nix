{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.clojure.enable = lib.mkEnableOption "Clojure development (JDK, clj CLI, LSP, linting, formatting)";

  config = lib.mkIf config.myConfig.modules.clojure.enable {
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
