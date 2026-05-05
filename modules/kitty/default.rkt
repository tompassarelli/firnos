#lang nisp

(module-file modules kitty
  (desc "Kitty terminal configuration")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    (home-of-bare 'username
      (set programs.kitty
        (att (enable #t)
             (settings
               (att (tab_bar_edge "top")
                    (tab_bar_style "powerline")
                    (window_padding_width "2 0 0 3"))))))))
