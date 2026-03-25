{ lib, ... }:
{
  options.myConfig.nodejs.enable = lib.mkEnableOption "Node.js runtime";
  imports = [ ./nodejs.nix ];
}
