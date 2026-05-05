#lang nisp

(module-file modules todoist
  (desc "Todoist task manager")
  (config-body
    (set 'environment.systemPackages (lst 'pkgs.todoist-electron))))
