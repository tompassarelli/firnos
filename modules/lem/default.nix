{ config, lib, pkgs, inputs, ... }:
let
  cfg = config.myConfig.modules.lem;
  username = config.myConfig.modules.users.username;
  # Patch out lem-terminal dependency — its terminal.so path gets baked into
  # the SBCL image but isn't a runtime dependency, so nix GCs it and SBCL
  # crashes on startup. Terminal emulation inside Lem isn't needed anyway.
  lem-ncurses = (inputs.lem.packages.x86_64-linux.lem-ncurses.overrideLispAttrs (o: {
    postPatch = (o.postPatch or "") + ''
      sed -i 's/#-os-windows "lem-terminal"//' lem.asd
    '';
  }));
in
{
  options.myConfig.modules.lem = {
    enable = lib.mkEnableOption "Lem Common Lisp editor";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      lem-ncurses
    ];

    home-manager.users.${username} = { config, ... }: {
      # Symlink lem config out of store for live editing
      home.file.".lem".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/code/nixos-config/dotfiles/lem";

      xdg.desktopEntries.lem = {
        name = "Lem";
        comment = "Common Lisp Editor";
        exec = "${pkgs.kitty}/bin/kitty ${lem-ncurses}/bin/lem";
        terminal = false;
        type = "Application";
        categories = [ "Development" "TextEditor" ];
      };
    };
  };
}
