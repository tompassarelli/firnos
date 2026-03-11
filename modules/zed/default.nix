{ lib, ... }:
{
  options.myConfig.zed = {
    enable = lib.mkEnableOption "Zed editor with MCP support";
  };

  imports = [
    ./zed.nix
  ];
}
