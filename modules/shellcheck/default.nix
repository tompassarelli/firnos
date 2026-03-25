{ lib, ... }:
{
  options.myConfig.modules.shellcheck.enable = lib.mkEnableOption "ShellCheck shell script linter";
  imports = [ ./shellcheck.nix ];
}
