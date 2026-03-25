{ lib, ... }:
{
  options.myConfig.curl.enable = lib.mkEnableOption "curl HTTP client";
  imports = [ ./curl.nix ];
}
