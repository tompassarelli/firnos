{ lib, ... }:
{
  options.myConfig.shellcheck.enable = lib.mkEnableOption "ShellCheck shell script linter";
  imports = [ ./shellcheck.nix ];
}
