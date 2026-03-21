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
          sops.age.keyFile = "/home/${config.myConfig.users.username}/.config/sops/age/keys.txt";

          # sops + age CLI tools for creating/editing encrypted secrets
          environment.systemPackages = with pkgs; [ sops age ];

          imports = [
            "${firnModules}/boot"
            "${firnModules}/kitty"
            "${firnModules}/fish"
            "${firnModules}/zoxide"
            "${firnModules}/atuin"
            "${firnModules}/starship"
            "${firnModules}/git"
            "${firnModules}/yazi"
            "${firnModules}/mako"
            "${firnModules}/gtk"
            "${firnModules}/kanata"
            "${firnModules}/glide"
            "${firnModules}/users"
            "${firnModules}/networking"
            "${firnModules}/wireguard"
            "${firnModules}/remmina"
            "${firnModules}/protonvpn"
            "${firnModules}/styling"
            "${firnModules}/timezone"
            "${firnModules}/nix-settings"
            "${firnModules}/ssh"
            "${firnModules}/auto-upgrade"
            "${firnModules}/pipewire"
            "${firnModules}/bluetooth"
            "${firnModules}/niri"
            "${firnModules}/input"
            "${firnModules}/wl-clipboard"
            "${firnModules}/brightnessctl"
            "${firnModules}/wl-gammarelay"
            "${firnModules}/piper"
            "${firnModules}/upower"
            "${firnModules}/polkit"
            "${firnModules}/gnome-keyring"
            "${firnModules}/theming"
            "${firnModules}/tree"
            "${firnModules}/dust"
            "${firnModules}/eza"
            "${firnModules}/procs"
            "${firnModules}/tealdeer"
            "${firnModules}/fastfetch"
            "${firnModules}/btop"
            "${firnModules}/rust"
            "${firnBundles}/development"
            "${firnModules}/firefox"
            "${firnModules}/chrome"
            "${firnModules}/steam"
            "${firnModules}/neovim"
            "${firnModules}/doom-emacs"
            "${firnBundles}/doom"
            "${firnBundles}/productivity"
            "${firnBundles}/creative"
            "${firnBundles}/media"
            "${firnBundles}/auth"
            "${firnModules}/password"
            "${firnModules}/mail"
            "${firnModules}/rofi"
            "${firnModules}/walker"
            "${firnModules}/waybar"
            "${firnModules}/quickshell"
            "${firnModules}/ironbar"
            "${firnModules}/framework"
            "${firnModules}/claude"
            "${firnModules}/theme-switcher"
            "${firnModules}/via"
            "${firnModules}/system"
            "${firnModules}/lem"
            "${firnModules}/zed"
            "${firnModules}/printing"
            "${firnModules}/postgresql"
            "${firnModules}/sqlcmd"
            "${firnModules}/direnv"
            "${firnModules}/dotnet"
            "${firnModules}/windows-vm"
            "${firnModules}/containers"
          ];

          # Home-manager configuration
          home-manager.backupFileExtension = "backup";
          home-manager.extraSpecialArgs = {
            inputs = { inherit nur walker elephant lem quickshell; };
          } // extraSpecialArgs;
          home-manager.users.${config.myConfig.users.username} = {
            home.stateVersion = config.myConfig.system.stateVersion;
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
