{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.vim.enable = lib.mkEnableOption "Vim text editor";

  config = lib.mkIf config.myConfig.modules.vim.enable {
    environment.systemPackages = [ pkgs.vim ];
  };
}
