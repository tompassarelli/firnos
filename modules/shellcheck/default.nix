{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.shellcheck.enable = lib.mkEnableOption "ShellCheck shell script linter";

  config = lib.mkIf config.myConfig.modules.shellcheck.enable {
    environment.systemPackages = [ pkgs.shellcheck ];
  };
}
