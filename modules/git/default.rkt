#lang nisp

(module-file modules git
  (desc "Git configuration")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    ;; ============ SYSTEM-LEVEL CONFIGURATION ============
    ;; (None needed - git is installed via home-manager)

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (home-of-bare 'username
      (set 'programs.git
        (att ('enable #t)
             ('settings
               (att ('user.name "tompassarelli")
                    ('user.email "tom.passarelli@protonmail.com")
                    ('init.defaultBranch "main")
                    ('core.editor "nvim")
                    ('merge.conflictstyle "diff3")
                    ('diff.colorMoved "default")))))
      (set 'programs.delta
        (att ('enable #t)
             ('enableGitIntegration #t)
             ('options (att ('navigate #t))))))))
