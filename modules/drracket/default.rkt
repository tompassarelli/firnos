#lang nisp

(module-file modules drracket
  (desc "DrRacket IDE")
  ;; Racket packages installed via raco (not available as nix derivations).
  ;; These get installed into ~/.local/share/racket/ per-user.
  (lets ([racoPackages (lst "drracket-vim-tool" "db")]
         [racoEnsure (call pkgs.writeShellScript "raco-ensure-packages"
                       (ms "for pkg in ${lib.concatStringsSep \" \" racoPackages}; do"
                           "  if ! ${pkgs.racket}/bin/raco pkg show \"$pkg\" 2>/dev/null | grep -q \"Package name:\"; then"
                           "    ${pkgs.racket}/bin/raco pkg install --auto --skip-installed \"$pkg\""
                           "  fi"
                           "done"))]))
  (config-body
    (set environment.systemPackages (with-pkgs racket))

    ;; Ensure raco packages are installed on activation
    (set system.activationScripts.racoPackages.text
      (ms "sudo -u ${config.myConfig.modules.users.username} ${racoEnsure} || true"))))
