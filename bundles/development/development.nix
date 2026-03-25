{ config, lib, ... }:

let
  cfg = config.myConfig.development;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.vim.enable = lib.mkDefault cfg.vim.enable;
    myConfig.claude.enable = lib.mkDefault cfg.claude.enable;
    myConfig.ripgrep.enable = lib.mkDefault cfg.ripgrep.enable;
    myConfig.fd.enable = lib.mkDefault cfg.fd.enable;
    myConfig.unzip.enable = lib.mkDefault cfg.unzip.enable;
    myConfig.parted.enable = lib.mkDefault cfg.parted.enable;
    myConfig.wget.enable = lib.mkDefault cfg.wget.enable;
    myConfig.curl.enable = lib.mkDefault cfg.curl.enable;
    myConfig.imagemagick.enable = lib.mkDefault cfg.imagemagick.enable;
    myConfig.ghostscript.enable = lib.mkDefault cfg.ghostscript.enable;
    myConfig.nodejs.enable = lib.mkDefault cfg.nodejs.enable;
    myConfig.python-dev.enable = lib.mkDefault cfg.python-dev.enable;
    myConfig.sqlite.enable = lib.mkDefault cfg.sqlite.enable;
    myConfig.dbeaver.enable = lib.mkDefault cfg.dbeaver.enable;
    myConfig.gh.enable = lib.mkDefault cfg.gh.enable;
    myConfig.delta.enable = lib.mkDefault cfg.delta.enable;
  };
}
