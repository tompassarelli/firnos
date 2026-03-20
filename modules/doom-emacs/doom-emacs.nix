{ config, lib, pkgs, flakeRoot, ... }:
let
  username = config.myConfig.users.username;
  chosenTheme = config.myConfig.theming.chosenTheme;
in
{
  config = lib.mkIf config.myConfig.doom-emacs.enable {
    # Install emacs and doom dependencies
    environment.systemPackages = with pkgs; [
      emacs           # Emacs 30.2
      git             # Required by Doom
      ripgrep         # Required by Doom
      fd              # Required by Doom
      coreutils       # Basic GNU utilities
      clang           # For vterm and some packages
      cmake           # For vterm compilation
      gnumake         # For vterm compilation
      gcc             # C compiler for vterm
      libtool         # For vterm compilation
      sbcl            # Common Lisp compiler
    ];

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
        startWithUserSession = "graphical";  # Wait for graphical session to get display vars
      };
    };
  };
}
