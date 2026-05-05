#lang nisp

(module-file modules starship
  (desc "starship prompt")
  (lets ([username config.myConfig.modules.users.username]))
  (config-body
    (home-of-bare username
      (set programs.starship
        (att (enable #t)
             (enableFishIntegration #t)
             (settings
               (att (add_newline #f)
                    (format
                      (call lib.concatStrings
                            (lst "$directory"
                                 ;; "$git_branch"
                                 ;; "$git_status"
                                 "$character")))
                    (directory
                      (att (truncation_length 0)
                           (truncate_to_repo #f)))
                    (character
                      (att (success_symbol "[λ](bold green)")
                           (error_symbol "[λ](bold red)")
                           (vimcmd_symbol "[λ](bold green)")))
                    (username.disabled #t)
                    (hostname.disabled #t))))))))
