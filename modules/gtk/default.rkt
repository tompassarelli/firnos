#lang nisp

(module-file modules gtk
  (desc "GTK theming configuration")
  (lets
    ([username 'config.myConfig.modules.users.username]
     ;; Get polarity from system-level stylix config
     [isDark (bop '== 'config.stylix.polarity "dark")]))
  (config-body
    ;; ============ SYSTEM-LEVEL CONFIGURATION ============
    ;; (None needed - gtk is configured via home-manager)

    ;; ============ HOME-MANAGER CONFIGURATION ============
    (nix-attr-entry
      (.> "home-manager" "users" 'username)
      (fn-set-rest (config)
        (let-in
          ([stylixGtkFont
            (cat (cat 'config.gtk.font.name " ")
                 (call 'toString 'config.gtk.font.size))]
           [stylixGtkTheme 'config.gtk.theme.name])
          (att
            ;; Let Stylix handle base GTK config
            (set gtk.enable #t)

            ;; Add GTK packages and gsettings schemas to fix GLib-GIO warnings
            (set home.packages (with-pkgs gsettings-desktop-schemas gtk3))

            ;; Override the settings.ini files to add dark mode preference
            ;; We read Stylix's values and add our dark mode setting
            (nix-attr-entry
              (.> "xdg" "configFile" "\"gtk-3.0/settings.ini\"" "text")
              (mkforce
                (ms "[Settings]"
                    "gtk-application-prefer-dark-theme=${if isDark then \"1\" else \"0\"}"
                    "gtk-font-name=${stylixGtkFont}"
                    "gtk-theme-name=${stylixGtkTheme}")))

            (nix-attr-entry
              (.> "xdg" "configFile" "\"gtk-4.0/settings.ini\"" "text")
              (mkforce
                (ms "[Settings]"
                    "gtk-application-prefer-dark-theme=${if isDark then \"1\" else \"0\"}"
                    "gtk-font-name=${stylixGtkFont}"
                    "gtk-theme-name=${stylixGtkTheme}")))

            ;; Set GTK color scheme preference for modern apps
            ;; Override Stylix's default setting dynamically based on polarity
            (set dconf.settings
              (att
                (nix-attr-entry
                  (.> "\"org/gnome/desktop/interface\"")
                  (att
                    (color-scheme (mkforce (if-then 'isDark "prefer-dark" "prefer-light"))))))))))) ))
