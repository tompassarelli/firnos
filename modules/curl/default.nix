{ lib, ... }:
{
  options.myConfig.modules.curl.enable = lib.mkEnableOption "curl HTTP client";
  imports = [ ./curl.nix ];
}
