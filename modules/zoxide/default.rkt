#lang nisp

(module-file modules zoxide
  (desc "zoxide smart directory jumper")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    (home-of-bare 'username
      (set 'programs.fish.shellAliases.cd "z")
      (set 'programs.zoxide
        (att ('enable #t)
             ('enableFishIntegration #t))))))
