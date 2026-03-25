{ lib, ... }:
{
  options.myConfig.modules.doom-emacs.enable = lib.mkEnableOption "Doom Emacs configuration (dotfiles, daemon, secrets)";
  imports = [ ./doom-emacs.nix ];
}
