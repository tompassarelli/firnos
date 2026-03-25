{ lib, ... }:
{
  options.myConfig.modules.zed = {
    enable = lib.mkEnableOption "Zed editor with MCP support";
  };

  imports = [
    ./zed.nix
  ];
}
