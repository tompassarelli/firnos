{ config, lib, ... }:

let
  cfg = config.myConfig.bundles.development;
in
{
  config = lib.mkIf cfg.enable {
    myConfig.modules.vim.enable = lib.mkDefault cfg.vim.enable;
    myConfig.modules.claude.enable = lib.mkDefault cfg.claude.enable;
    myConfig.modules.ripgrep.enable = lib.mkDefault cfg.ripgrep.enable;
    myConfig.modules.fd.enable = lib.mkDefault cfg.fd.enable;
    myConfig.modules.unzip.enable = lib.mkDefault cfg.unzip.enable;
    myConfig.modules.parted.enable = lib.mkDefault cfg.parted.enable;
    myConfig.modules.wget.enable = lib.mkDefault cfg.wget.enable;
    myConfig.modules.curl.enable = lib.mkDefault cfg.curl.enable;
    myConfig.modules.imagemagick.enable = lib.mkDefault cfg.imagemagick.enable;
    myConfig.modules.ghostscript.enable = lib.mkDefault cfg.ghostscript.enable;
    myConfig.modules.nodejs.enable = lib.mkDefault cfg.nodejs.enable;
    myConfig.bundles.python-dev.enable = lib.mkDefault cfg.python-dev.enable;
    myConfig.modules.sqlite.enable = lib.mkDefault cfg.sqlite.enable;
    myConfig.modules.dbeaver.enable = lib.mkDefault cfg.dbeaver.enable;
    myConfig.modules.gh.enable = lib.mkDefault cfg.gh.enable;
    myConfig.modules.delta.enable = lib.mkDefault cfg.delta.enable;
  };
}
