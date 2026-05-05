#lang nisp

(hm-module atuin "atuin shell history sync"
  (set programs.atuin
    (att (enable #t)
         (enableFishIntegration #t)
         (settings
           (att (auto_sync #t)
                (sync_frequency "5m")
                (search_mode "fuzzy"))))))
