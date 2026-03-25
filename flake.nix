{
  description = "FirnOS - A modular, shareable NixOS configuration framework";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:nixos/nixpkgs/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix.url = "github:danth/stylix/release-25.05";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur.url = "github:nix-community/NUR";
    # Lem - Common Lisp editor
    lem.url = "github:lem-project/lem";

    # Kanata from upstream main (has tap-hold-order, not yet in a release)
    kanata-git = {
      url = "github:jtroo/kanata";
      flake = false;
    };

    # Glide - touchpad motion detection daemon for kanata
    glide = {
      url = "github:tompassarelli/glide";
      flake = false;
    };

    # Quickshell - Qt6/QML shell toolkit
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    elephant.url = "github:abenz1267/elephant/0348d14ed9238309d2ae984f5010877470b06a73";
    walker = {
      url = "github:abenz1267/walker";
      inputs.elephant.follows = "elephant";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-master, home-manager, stylix, sops-nix, nur, lem, elephant, walker, kanata-git, glide, quickshell }:
    let
      # All available modules - can be imported by external configs
      firnModules = ./modules;
      firnBundles = ./bundles;
    in {
    # ============================================================
    # PUBLIC API: Use these from your own flake
    # ============================================================

    # Reusable system builder function
    #
    # Usage from external flake:
    #   nixos-config.lib.mkSystem {
    #     hostname = "my-machine";
    #     hostConfig = ./hosts/my-machine/configuration.nix;
    #     hardwareConfig = ./hosts/my-machine/hardware-configuration.nix;
    #   }
    #
    lib.mkSystem = {
      hostname,
      hostConfig,
      hardwareConfig,
      system ? "x86_64-linux",
      extraModules ? [],
      extraOverlays ? [],
      extraSpecialArgs ? {},
    }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inputs = { inherit nur walker elephant lem quickshell; };
        flakeRoot = self;
      } // extraSpecialArgs;
      modules = [
        hardwareConfig

        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops

        # Host-specific configuration (module enables, username, etc.)
        hostConfig

        # ============ FIRN MODULES ============
        ({ config, pkgs, ... }: {
          networking.hostName = hostname;

          # sops-nix: use age key from user's home for both CLI editing and activation
          sops.age.keyFile = "/home/${config.myConfig.modules.users.username}/.config/sops/age/keys.txt";

          # sops + age CLI tools for creating/editing encrypted secrets
          environment.systemPackages = with pkgs; [ sops age ];

          imports =
            let
              moduleDirs = builtins.attrNames
                (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./modules));
              bundleDirs = builtins.attrNames
                (nixpkgs.lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./bundles));
            in
              (map (m: "${firnModules}/${m}") moduleDirs)
              ++ (map (b: "${firnBundles}/${b}") bundleDirs);

          # Home-manager configuration
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            inputs = { inherit nur walker elephant lem quickshell; };
          } // extraSpecialArgs;
          home-manager.users.${config.myConfig.modules.users.username} = {
            home.stateVersion = config.myConfig.modules.system.stateVersion;
            nixpkgs.config.allowUnfree = true;
          };
        })

        # Overlays: unstable, master, and user-provided
        {
          nixpkgs.overlays = [
            (final: prev: {
              unstable = import nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
              master = import nixpkgs-master {
                inherit system;
                config.allowUnfree = true;
              };
              kanata-git = final.unstable.kanata.overrideAttrs (old: {
                src = kanata-git;
                version = "git";
                cargoDeps = final.unstable.rustPlatform.importCargoLock {
                  lockFile = "${kanata-git}/Cargo.lock";
                };
                doCheck = false;
                doInstallCheck = false;
              });
              glide = final.unstable.rustPlatform.buildRustPackage {
                pname = "glide";
                version = "git";
                src = glide;
                cargoLock.lockFile = "${glide}/Cargo.lock";
              };
              nyxt4 = let
                nyxt-tarball = final.fetchurl {
                  url = "https://github.com/atlas-engineer/nyxt/releases/download/4.0.0/Linux-Nyxt-x86_64.tar.gz";
                  hash = "sha256-v+x6K5svLA3L+IjEdTjmJEf3hvgwhwrvqAcelpY1ScQ=";
                };
                # Extract the outer Nyxt AppImage
                nyxt-appimage = final.runCommand "nyxt.AppImage" {} ''
                  tar xzf ${nyxt-tarball} -O > $out
                  chmod +x $out
                '';
                nyxt-extracted = final.appimageTools.extractType2 {
                  pname = "nyxt";
                  version = "4.0.0";
                  src = nyxt-appimage;
                };
                # Extract the inner cl-electron-server AppImage
                cl-electron-extracted = final.appimageTools.extractType2 {
                  pname = "cl-electron-server";
                  version = "4.0.0";
                  src = "${nyxt-extracted}/usr/bin/cl-electron-server";
                };
                # Assemble the final /app/Nyxt tree
                nyxt-unwrapped = final.runCommand "nyxt-unwrapped-4.0.0" {} ''
                  mkdir -p $out/app/Nyxt/_build/cl-electron $out/share/applications $out/share/icons/hicolor/256x256/apps

                  # Nyxt binary and libs
                  cp ${nyxt-extracted}/usr/bin/nyxt $out/app/Nyxt/
                  cp -r ${nyxt-extracted}/usr/lib/* $out/app/Nyxt/ 2>/dev/null || true

                  # cl-electron (full Electron distribution)
                  cp -r ${cl-electron-extracted}/* $out/app/Nyxt/_build/cl-electron/

                  # Desktop integration
                  cp ${nyxt-extracted}/nyxt.desktop $out/share/applications/ 2>/dev/null || true
                  cp ${nyxt-extracted}/nyxt.png $out/share/icons/hicolor/256x256/apps/ 2>/dev/null || true
                  sed -i "s|Exec=.*|Exec=nyxt %u|" $out/share/applications/nyxt.desktop 2>/dev/null || true
                '';

              in final.buildFHSEnv {
                pname = "nyxt";
                version = "4.0.0";
                targetPkgs = p: with p; [
                  nyxt-unwrapped
                  glib gobject-introspection gdk-pixbuf cairo pango gtk3
                  webkitgtk_4_1 openssl libfixposix enchant2 sqlite
                  glib-networking gsettings-desktop-schemas
                  gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-good
                  xdg-utils wl-clipboard fuse
                  nss nspr atk cups dbus expat libdrm mesa
                  alsa-lib at-spi2-core libxkbcommon
                ];
                extraBwrapArgs = [
                  "--bind ${nyxt-unwrapped}/app /app"
                ];
                runScript = "/app/Nyxt/nyxt";
                extraInstallCommands = ''
                  mkdir -p $out/share
                  ln -s ${nyxt-unwrapped}/share/applications $out/share/applications
                  ln -s ${nyxt-unwrapped}/share/icons $out/share/icons
                '';
              };
            })
          ] ++ extraOverlays;
        }
      ] ++ extraModules;
    };

    # Expose modules path for users who want to import individual modules
    modules = firnModules;

    # ============================================================
    # TOM'S PERSONAL CONFIGURATIONS
    # (Example usage - users create their own in their firnos repo)
    # ============================================================

    # Container images
    packages.x86_64-linux.claude-sandbox =
      let
        pkgs = import nixpkgs-master {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      in import ./modules/containers/claude-sandbox.nix { inherit pkgs; };

    nixosConfigurations = {
      whiterabbit = self.lib.mkSystem {
        hostname = "whiterabbit";
        hostConfig = ./hosts/whiterabbit/configuration.nix;
        hardwareConfig = ./hardware-configuration.nix;
      };

      thinkpad-x1e = self.lib.mkSystem {
        hostname = "thinkpad-x1e";
        hostConfig = ./hosts/thinkpad-x1e/configuration.nix;
        hardwareConfig = ./hardware-configuration.nix;
      };
    };

    # Flake template: nix flake init -t github:tompassarelli/firnos
    templates.default = {
      description = "FirnOS starter configuration";
      path = ./template;
    };

    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in pkgs.mkShell {
      packages = [ pkgs.pre-commit pkgs.gitleaks ];
      shellHook = ''
        pre-commit install --allow-missing-config 2>/dev/null
      '';
    };
  };
}
