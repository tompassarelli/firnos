{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.myConfig.modules.lem;
  username = config.myConfig.modules.users.username;
  lem-ncurses = inputs.lem.packages.x86_64-linux.lem-ncurses.overrideLispAttrs (o: {
    postPatch = o.postPatch or "" + ''
      sed -i 's/#-os-windows "lem-terminal"//' lem.asd
    '';
  });
in
{
  options.myConfig.modules.lem.enable = lib.mkEnableOption "Lem Common Lisp editor";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ lem-ncurses ];
    home-manager.users.${username} = { config, ... }: {
      home.file.".lem".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/lem";
      xdg.desktopEntries.lem = {
        name = "Lem";
        comment = "Common Lisp Editor";
        exec = "${pkgs.unstable.ghostty}/bin/ghostty -e ${lem-ncurses}/bin/lem";
        terminal = false;
        type = "Application";
        categories = [ "Development" "TextEditor" ];
      };
    };
  };
}
