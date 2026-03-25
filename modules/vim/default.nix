{ lib, ... }:
{
  options.myConfig.vim.enable = lib.mkEnableOption "Vim text editor";
  imports = [ ./vim.nix ];
}
