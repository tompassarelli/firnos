#lang nisp

(flake-file
  (description "FirnOS - A modular, shareable NixOS configuration framework")

  (inputs
    (nixpkgs           "github:nixos/nixpkgs/nixos-25.11")
    (nixpkgs-unstable  "github:nixos/nixpkgs/nixos-unstable")
    (nixpkgs-master    "github:nixos/nixpkgs/master")
    (home-manager      "github:nix-community/home-manager/release-25.11" (follows nixpkgs))
    (nix-darwin        "github:LnL7/nix-darwin/nix-darwin-25.11" (follows nixpkgs))
    (stylix            "github:danth/stylix/release-25.11")
    (sops-nix          "github:Mic92/sops-nix" (follows nixpkgs))
    (nur               "github:nix-community/NUR")
    (lem               "github:lem-project/lem")
    (kanata-git        "github:jtroo/kanata" (no-flake))
    (glide             "github:tompassarelli/glide" (no-flake))
    (quickshell        "git+https://git.outfoxxed.me/outfoxxed/quickshell"
                       (follows nixpkgs nixpkgs-unstable))
    (zen-browser       "github:0xc000022070/zen-browser-flake" (follows nixpkgs))
    (elephant          "github:abenz1267/elephant/0348d14ed9238309d2ae984f5010877470b06a73")
    (walker            "github:abenz1267/walker" (follows elephant))
    (palefox           "github:tompassarelli/palefox")
    (gjoa              "github:tompassarelli/gjoa"))

  (outputs (self nixpkgs nixpkgs-unstable nixpkgs-master home-manager nix-darwin
                 stylix sops-nix nur lem elephant walker kanata-git glide quickshell
                 zen-browser palefox gjoa)
    (let-in
      ([firnModules (p "./modules")]
       [firnBundles (p "./bundles")]
       [firnBundlesDarwin (p "./bundles-darwin")])
      (att
        ;; ============================================================
        ;; PUBLIC API: Reusable system builder
        ;; ============================================================
        (lib.mkSystem
          (fn-set-rest
            (hostname
             hostConfig
             hardwareConfig
             (system "x86_64-linux")
             (extraModules     (lst))
             (extraOverlays    (lst))
             (extraSpecialArgs (att)))
            (call nixpkgs.lib.nixosSystem
              (att
                (system system)
                (specialArgs
                  (merge
                    (att
                      (inputs (att
                                (nur nur)
                                (walker walker)
                                (elephant elephant)
                                (lem lem)
                                (quickshell quickshell)
                                (zen-browser zen-browser)
                                (palefox palefox)
                                (gjoa gjoa)))
                      (flakeRoot self))
                    extraSpecialArgs))
                (modules
                  (concat-list
                    (lst
                      hardwareConfig
                      stylix.nixosModules.stylix
                      home-manager.nixosModules.home-manager
                      sops-nix.nixosModules.sops
                      hostConfig

                      ;; ============ FIRN MODULES (inline module) ============
                      (fn-set-rest (config pkgs)
                        (att
                          (networking.hostName hostname)

                          ;; sops-nix key path: lives in /var/lib/sops-nix so it's
                          ;; readable at stage-2-init (before /home is mounted).
                          (sops.age.keyFile "/var/lib/sops-nix/key.txt")
                          (environment.sessionVariables.SOPS_AGE_KEY_FILE
                            "/var/lib/sops-nix/key.txt")

                          ;; Enforce ownership/mode on the key file every activation
                          ;; so perms can't drift.
                          (systemd.tmpfiles.rules
                            (lst
                              (s "z /var/lib/sops-nix/key.txt 0400 "
                                 config.myConfig.modules.users.username
                                 " users -")))

                          ;; sops + age CLI tools for editing encrypted secrets
                          (environment.systemPackages (with-pkgs sops age))

                          ;; Discover modules/bundles dynamically from the directory tree.
                          (imports
                            (let-in
                              ([moduleDirs
                                (call builtins.attrNames
                                  (call nixpkgs.lib.filterAttrs
                                    (fn (n v) (== v (s "directory")))
                                    (call builtins.readDir (p "./modules"))))]
                               [bundleDirs
                                (call builtins.attrNames
                                  (call nixpkgs.lib.filterAttrs
                                    (fn (n v) (== v (s "directory")))
                                    (call builtins.readDir (p "./bundles"))))])
                              (concat-list
                                (call map
                                  (fn m (s firnModules "/" m))
                                  moduleDirs)
                                (call map
                                  (fn b (s firnBundles "/" b))
                                  bundleDirs))))

                          ;; Home-manager configuration
                          (home-manager.backupFileExtension "backup")
                          (home-manager.extraSpecialArgs
                            (merge
                              (att
                                (inputs (att
                                          (nur nur)
                                          (walker walker)
                                          (elephant elephant)
                                          (lem lem)
                                          (quickshell quickshell)
                                          (zen-browser zen-browser)
                                          (palefox palefox)
                                          (gjoa gjoa))))
                              extraSpecialArgs))
                          (home-of-bare config.myConfig.modules.users.username
                            (set home.stateVersion config.myConfig.modules.system.stateVersion)
                            (set nixpkgs.config.allowUnfree #t))))

                      ;; ============ OVERLAYS ============
                      (att
                        (nixpkgs.overlays
                          (concat-list
                            (lst
                              (fn (final prev)
                                (att
                                  (unstable
                                    (call import nixpkgs-unstable
                                      (att (system system)
                                           (config.allowUnfree #t))))
                                  (master
                                    (call import nixpkgs-master
                                      (att (system system)
                                           (config.allowUnfree #t))))
                                  (kanata-git
                                    (call final.unstable.kanata.overrideAttrs
                                      (fn old
                                        (att
                                          (src kanata-git)
                                          (version "git")
                                          (cargoDeps
                                            (call final.unstable.rustPlatform.importCargoLock
                                              (att (lockFile (s kanata-git "/Cargo.lock")))))
                                          (doCheck #f)
                                          (doInstallCheck #f)))))
                                  (glide
                                    (call final.unstable.rustPlatform.buildRustPackage
                                      (att
                                        (pname "glide")
                                        (version "git")
                                        (src glide)
                                        (cargoLock.lockFile (s glide "/Cargo.lock")))))
                                  (nyxt4
                                    (let-in
                                      ([nyxt-tarball
                                        (call final.fetchurl
                                          (att
                                            (url "https://github.com/atlas-engineer/nyxt/releases/download/4.0.0/Linux-Nyxt-x86_64.tar.gz")
                                            (hash "sha256-v+x6K5svLA3L+IjEdTjmJEf3hvgwhwrvqAcelpY1ScQ=")))]
                                       [nyxt-appimage
                                        (call final.runCommand
                                          "nyxt.AppImage"
                                          (att)
                                          (ms "tar xzf ${nyxt-tarball} -O > $out"
                                              "chmod +x $out"))]
                                       [nyxt-extracted
                                        (call final.appimageTools.extractType2
                                          (att
                                            (pname "nyxt")
                                            (version "4.0.0")
                                            (src nyxt-appimage)))]
                                       [cl-electron-extracted
                                        (call final.appimageTools.extractType2
                                          (att
                                            (pname "cl-electron-server")
                                            (version "4.0.0")
                                            (src (s nyxt-extracted "/usr/bin/cl-electron-server"))))]
                                       [nyxt-unwrapped
                                        (call final.runCommand
                                          "nyxt-unwrapped-4.0.0"
                                          (att)
                                          (ms
                                            "mkdir -p $out/app/Nyxt/_build/cl-electron $out/share/applications $out/share/icons/hicolor/256x256/apps"
                                            ""
                                            "# Nyxt binary and libs"
                                            "cp ${nyxt-extracted}/usr/bin/nyxt $out/app/Nyxt/"
                                            "cp -r ${nyxt-extracted}/usr/lib/* $out/app/Nyxt/ 2>/dev/null || true"
                                            ""
                                            "# cl-electron (full Electron distribution)"
                                            "cp -r ${cl-electron-extracted}/* $out/app/Nyxt/_build/cl-electron/"
                                            ""
                                            "# Desktop integration"
                                            "cp ${nyxt-extracted}/nyxt.desktop $out/share/applications/ 2>/dev/null || true"
                                            "cp ${nyxt-extracted}/nyxt.png $out/share/icons/hicolor/256x256/apps/ 2>/dev/null || true"
                                            "sed -i \"s|Exec=.*|Exec=nyxt %u|\" $out/share/applications/nyxt.desktop 2>/dev/null || true"))])
                                      (call final.buildFHSEnv
                                        (att
                                          (pname "nyxt")
                                          (version "4.0.0")
                                          (targetPkgs
                                            (fn p
                                              (with-do p
                                                (lst
                                                  nyxt-unwrapped
                                                  glib gobject-introspection gdk-pixbuf cairo pango gtk3
                                                  webkitgtk_4_1 openssl libfixposix enchant2 sqlite
                                                  glib-networking gsettings-desktop-schemas
                                                  gst_all_1.gstreamer
                                                  gst_all_1.gst-plugins-base
                                                  gst_all_1.gst-plugins-good
                                                  xdg-utils wl-clipboard fuse
                                                  nss nspr atk cups dbus expat libdrm mesa libgbm
                                                  alsa-lib at-spi2-core libxkbcommon pciutils
                                                  xorg.libX11 xorg.libXcomposite xorg.libXdamage xorg.libXext
                                                  xorg.libXfixes xorg.libXrandr xorg.libxcb xorg.libXcursor
                                                  xorg.libXi xorg.libXrender xorg.libXtst xorg.libXScrnSaver
                                                  systemd libGL libglvnd egl-wayland))))
                                          (extraBwrapArgs
                                            (lst (s "--bind " nyxt-unwrapped "/app /app")))
                                          (runScript
                                            (call final.writeShellScript "nyxt-wrapper"
                                              (ms
                                                "export APPDIR=/app/Nyxt"
                                                "export PATH=\"/app/Nyxt/_build/cl-electron:$PATH\""
                                                "export ELECTRON_OZONE_PLATFORM_HINT=auto"
                                                "exec /app/Nyxt/nyxt \"$@\"")))
                                          (extraInstallCommands
                                            (ms
                                              "mkdir -p $out/share"
                                              "ln -s ${nyxt-unwrapped}/share/applications $out/share/applications"
                                              "ln -s ${nyxt-unwrapped}/share/icons $out/share/icons")))))))))
                            extraOverlays))))
                    extraModules))))))

        ;; ============================================================
        ;; PUBLIC API: Reusable system builder (macOS / nix-darwin)
        ;; ------------------------------------------------------------
        ;; Mirrors mkSystem but targets nix-darwin instead of NixOS.
        ;; Skips NixOS-only modules (stylix, sops-nix, hardwareConfig,
        ;; systemd-tmpfiles). Reuses the same auto-discovered
        ;; modules/bundles tree — `mkIf cfg.enable` gating means
        ;; NixOS-only modules are inert when not enabled.
        ;; ============================================================
        (lib.mkDarwinSystem
          (fn-set-rest
            (hostname
             hostConfig
             (system "aarch64-darwin")
             (extraModules     (lst))
             (extraOverlays    (lst))
             (extraSpecialArgs (att)))
            (call nix-darwin.lib.darwinSystem
              (att
                (system system)
                (specialArgs
                  (merge
                    (att
                      (inputs (att
                                (nur nur)
                                (palefox palefox)
                                (gjoa gjoa)))
                      (flakeRoot self))
                    extraSpecialArgs))
                (modules
                  (concat-list
                    (lst
                      home-manager.darwinModules.home-manager
                      hostConfig

                      ;; ============ FIRN MODULES (inline module, darwin) ============
                      ;; Explicit imports/options/config split. Other modules
                      ;; (modules/git, modules/atuin, …) reference
                      ;; config.myConfig.modules.users.username, but
                      ;; modules/users isn't in the darwin allowlist (its
                      ;; config-body touches NixOS-only options). So we
                      ;; declare the option here.
                      ;;
                      ;; Module + bundle allowlist for darwin: mkIf gating
                      ;; *defers the value*, but nix-darwin's option system
                      ;; still rejects undeclared option *paths* (boot.*,
                      ;; hardware.*, etc.). So we can't reuse the full NixOS
                      ;; auto-discovery tree.
                      ;;
                      ;; Strategy:
                      ;;   - Bundles live in `bundles-darwin/`, auto-discovered
                      ;;     wholesale. They share the `myConfig.bundles.<name>`
                      ;;     namespace with their NixOS siblings, so a host
                      ;;     can do `(enable myConfig.bundles.terminal)` on
                      ;;     either platform and get the right composition.
                      ;;   - Modules are an explicit safelist below — every
                      ;;     module referenced by any darwin bundle, plus
                      ;;     extras a darwin host might want directly.
                      ;;     Adding a module: confirm its config-body only
                      ;;     touches programs.*, environment.systemPackages,
                      ;;     or home-manager.*, then append to the list.
                      (fn-set-rest (config lib pkgs)
                        (att
                          (imports
                            (concat-list
                              ;; modules/<name> safelist
                              (call map
                                (fn m (s firnModules "/" m))
                                (lst
                                  ;; bundles-darwin/terminal
                                  "kitty" "fish" "zoxide" "atuin" "starship"
                                  ;; bundles-darwin/cli-tools
                                  "yazi" "tree" "dust" "eza" "procs" "tealdeer"
                                  "fastfetch" "btop" "unrar" "curl" "wget" "unzip"
                                  "imagemagick" "ghostscript"
                                  ;; bundles-darwin/development
                                  "git" "gh" "delta" "vim" "claude" "direnv"
                                  "ripgrep" "fd"))
                              ;; bundles-darwin/* — auto-discovered
                              (call map
                                (fn b (s firnBundlesDarwin "/" b))
                                (call builtins.attrNames
                                  (call nixpkgs.lib.filterAttrs
                                    (fn (n v) (== v (s "directory")))
                                    (call builtins.readDir (p "./bundles-darwin")))))))

                          (options.myConfig.modules.users.username
                            (call lib.mkOption
                              (att (type lib.types.str)
                                   (default "you")
                                   (description "Primary system username"))))

                          (config
                            (att
                              (networking.hostName hostname)

                              ;; nix-darwin requires this to track which
                              ;; version of nix-darwin built the system.
                              (system.stateVersion 6)

                              ;; allowUnfree at the system level (matches
                              ;; the NixOS path; some darwin-safe modules
                              ;; like unrar pull unfree dependencies).
                              (nixpkgs.config.allowUnfree #t)

                              ;; nix-darwin's home-manager module derives
                              ;; home.username/homeDirectory from
                              ;; users.users.<name>. The macOS account already
                              ;; exists outside Nix; just declare the entry so
                              ;; the lookup resolves. nix-darwin defaults
                              ;; .name and .home from the attr name.
                              (users.users
                                (att ("${config.myConfig.modules.users.username}"
                                      (att (home (s "/Users/"
                                                    config.myConfig.modules.users.username))))))

                              ;; Home-manager configuration
                              (home-manager.backupFileExtension "backup")
                              (home-manager.extraSpecialArgs
                                (merge
                                  (att
                                    (inputs (att
                                              (nur nur)
                                              (palefox palefox)
                                              (gjoa gjoa))))
                                  extraSpecialArgs))
                              (home-of-bare config.myConfig.modules.users.username
                                ;; home-manager defaults home.username and
                                ;; home.homeDirectory from config.users.users.<n>,
                                ;; but we don't import modules/users on darwin —
                                ;; the friend's macOS account already exists.
                                ;; Set them explicitly so home-manager can attach.
                                (set home.username config.myConfig.modules.users.username)
                                (set home.homeDirectory
                                     (s "/Users/" config.myConfig.modules.users.username))
                                (set home.stateVersion "25.11")
                                (set nixpkgs.config.allowUnfree #t))))))

                      ;; ============ OVERLAYS (darwin) ============
                      (att
                        (nixpkgs.overlays
                          (concat-list
                            (lst
                              (fn (final prev)
                                (att
                                  (unstable
                                    (call import nixpkgs-unstable
                                      (att (system system)
                                           (config.allowUnfree #t))))
                                  (master
                                    (call import nixpkgs-master
                                      (att (system system)
                                           (config.allowUnfree #t)))))))
                            extraOverlays))))
                    extraModules))))))

        ;; Expose modules path for users who want to import individual modules
        (modules firnModules)

        ;; Container image (built directly, not via mkSystem)
        (packages.x86_64-linux.claude-sandbox
          (call import (p "./modules/containers/claude-sandbox.nix")
            (att (pkgs (call import nixpkgs-master
                         (att (system "x86_64-linux")
                              (config.allowUnfree #t)))))))

        ;; Tom's personal hosts (NixOS)
        (nixosConfigurations
          (att
            (whiterabbit
              (call self.lib.mkSystem
                (att
                  (hostname "whiterabbit")
                  (hostConfig (p "./hosts/whiterabbit/configuration.nix"))
                  (hardwareConfig (p "./hardware-configuration.nix")))))
            (thinkpad-x1e
              (call self.lib.mkSystem
                (att
                  (hostname "thinkpad-x1e")
                  (hostConfig (p "./hosts/thinkpad-x1e/configuration.nix"))
                  (hardwareConfig (p "./hardware-configuration.nix")))))))

        ;; macOS hosts (nix-darwin) — see docs/MACOS.md
        (darwinConfigurations
          (att
            (ashashi
              (call self.lib.mkDarwinSystem
                (att
                  (hostname "ashashi")
                  (hostConfig (p "./hosts/ashashi/configuration.nix")))))))

        ;; Flake template: nix flake init -t github:tompassarelli/firnos
        (templates.default
          (att
            (description "FirnOS starter configuration")
            (path (p "./template"))))

        (devShells.x86_64-linux.default
          (let-in
            ([pkgs nixpkgs.legacyPackages.x86_64-linux])
            (call pkgs.mkShell
              (att
                (packages (lst pkgs.pre-commit pkgs.gitleaks))
                (shellHook
                  (ms "pre-commit install --allow-missing-config 2>/dev/null"))))))))))
