{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.myConfig.vim.enable {
    environment.systemPackages = [ pkgs.vim ];
  };
}
