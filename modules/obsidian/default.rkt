#lang nisp

(module-file modules obsidian
  (desc "Obsidian note-taking")
  (config-body
    (set environment.systemPackages (with-pkgs obsidian))))
