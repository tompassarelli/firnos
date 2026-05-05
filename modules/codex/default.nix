{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.codex;
in
{
  options.myConfig.modules.codex.enable = lib.mkEnableOption "OpenAI Codex CLI (master/bleeding-edge)";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.master.codex ];
  };
}
