#lang nisp

(module-file modules yazi
  (desc "Yazi file manager")
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of-bare username
      (set programs.yazi
        (att (enable #t)
             (settings
               (att (opener
                      (att (edit
                             (lst (att (run "nvim \"$@\"")
                                       (block #t)
                                       (for "unix")))))))))))))
