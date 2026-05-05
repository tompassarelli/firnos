#lang nisp

(module-file modules codex
  (desc "OpenAI Codex CLI (master/bleeding-edge)")
  (config-body
    (set environment.systemPackages (lst pkgs.master.codex))))
