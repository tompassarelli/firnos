{ lib, ... }:
{
  options.myConfig.modules.nodejs.enable = lib.mkEnableOption "Node.js runtime";
  imports = [ ./nodejs.nix ];
}
