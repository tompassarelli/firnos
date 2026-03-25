{ lib, ... }:
{
  options.myConfig.modules.fd.enable = lib.mkEnableOption "fd file finder";
  imports = [ ./fd.nix ];
}
