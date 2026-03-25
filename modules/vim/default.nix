{ lib, ... }:
{
  options.myConfig.modules.vim.enable = lib.mkEnableOption "Vim text editor";
  imports = [ ./vim.nix ];
}
