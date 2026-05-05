#lang nisp

(module-file modules vscode
  (desc "Visual Studio Code (Microsoft build)")
  (config-body
    (set environment.systemPackages (lst pkgs.unstable.vscode))))
