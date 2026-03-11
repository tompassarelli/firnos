{ lib, ... }:
{
  options.myConfig.claude = {
    enable = lib.mkEnableOption "Claude Code CLI configuration";
  };

  imports = [
    ./claude.nix
  ];
}
