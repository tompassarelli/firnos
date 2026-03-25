{ config, lib, pkgs, flakeRoot, ... }:
let
  cfg = config.myConfig.bundles.doom-emacs;
  username = config.myConfig.modules.users.username;
  chosenTheme = config.myConfig.modules.stylix.chosenTheme;
in
{
  config = lib.mkIf cfg.enable {
    # Enable atomic modules
    myConfig.modules.emacs.enable = lib.mkDefault cfg.emacs.enable;
    myConfig.modules.nerd-fonts.enable = lib.mkDefault cfg.nerd-fonts.enable;
    myConfig.modules.ripgrep.enable = lib.mkDefault cfg.ripgrep.enable;
    myConfig.modules.fd.enable = lib.mkDefault cfg.fd.enable;
    myConfig.modules.clang.enable = lib.mkDefault cfg.clang.enable;
    myConfig.modules.cmake.enable = lib.mkDefault cfg.cmake.enable;
    myConfig.modules.gnumake.enable = lib.mkDefault cfg.gnumake.enable;
    myConfig.modules.gcc.enable = lib.mkDefault cfg.gcc.enable;
    myConfig.modules.libtool.enable = lib.mkDefault cfg.libtool.enable;
    myConfig.modules.sbcl.enable = lib.mkDefault cfg.sbcl.enable;
    myConfig.modules.gnome-screenshot.enable = lib.mkDefault cfg.gnome-screenshot.enable;
    myConfig.modules.graphviz.enable = lib.mkDefault cfg.graphviz.enable;
    myConfig.modules.shellcheck.enable = lib.mkDefault cfg.shellcheck.enable;

    # Clockify API key (decrypted to /run/secrets/msa-clockify-api-key)
    sops.secrets."msa-clockify-api-key" = {
      sopsFile = flakeRoot + "/secrets/clockify.yaml";
      owner = username;
    };

    # HOME-MANAGER: Doom config and environment
    home-manager.users.${username} = { config, ... }: {
      # Symlink doom config directory (out of store for live editing)
      home.file.".config/doom".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/doom";

      # Set DOOMDIR and theme environment variables
      home.sessionVariables = {
        DOOMDIR = "${config.home.homeDirectory}/.config/doom";
        NIXOS_THEME = chosenTheme;
      };

      # Add doom bin to PATH (fish-specific)
      programs.fish.interactiveShellInit = ''
        fish_add_path ~/.config/emacs/bin
      '';

      # Clone Doom Emacs framework on activation
      home.activation.cloneDoomEmacs = config.lib.dag.entryAfter ["writeBoundary"] ''
        DOOM_DIR="${config.home.homeDirectory}/.config/emacs"

        # Clone Doom if not present
        if [ ! -d "$DOOM_DIR" ]; then
          $DRY_RUN_CMD ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs "$DOOM_DIR"
          echo "Doom Emacs cloned to ~/.config/emacs"
          echo "Run: ~/.config/emacs/bin/doom install"
        fi
      '';

      # Enable Emacs daemon for instant startup with emacsclient
      services.emacs = {
        enable = true;
        package = pkgs.emacs;
        startWithUserSession = "graphical";
      };
    };
  };
}
