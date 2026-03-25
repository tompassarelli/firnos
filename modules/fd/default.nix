{ lib, ... }:
{
  options.myConfig.fd.enable = lib.mkEnableOption "fd file finder";
  imports = [ ./fd.nix ];
}
