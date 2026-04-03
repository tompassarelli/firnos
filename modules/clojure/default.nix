{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.clojure.enable = lib.mkEnableOption "Clojure development (JDK, clj CLI, LSP, linting, formatting)";

  config = lib.mkIf config.myConfig.modules.clojure.enable {
    environment.systemPackages = with pkgs.unstable; [
      jdk21       # JVM runtime
      clojure     # clj CLI + deps.edn toolchain

      # -- doom emacs :lang clojure -- do not remove --
      clj-kondo    # :checkers syntax (flycheck-clj-kondo)
      clojure-lsp  # +lsp
      neil         # neil.el — project scaffolding + dep management from Emacs
      jet          # jet.el — JSON/EDN/Transit conversion
      cljfmt       # :editor format
      # -- end doom emacs --
    ];
  };
}
