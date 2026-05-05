#lang nisp

(module-file modules atuin
  (desc "atuin shell history sync")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    (home-of 'username
      (set 'programs.atuin
        (att ('enable #t)
             ('enableFishIntegration #t)
             ('settings
               (att ('auto_sync #t)
                    ('sync_frequency "5m")
                    ('search_mode "fuzzy"))))))))
