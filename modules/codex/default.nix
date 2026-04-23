{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.codex.enable = lib.mkEnableOption "OpenAI Codex CLI (master/bleeding-edge)";

  config = lib.mkIf config.myConfig.modules.codex.enable {
    environment.systemPackages = [ pkgs.master.codex ];
  };
}
