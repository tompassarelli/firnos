{ lib, ... }:
{
  options.myConfig.modules.claude = {
    enable = lib.mkEnableOption "Claude Code CLI configuration";
  };

  imports = [
    ./claude.nix
  ];
}
