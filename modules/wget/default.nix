{ lib, ... }:
{
  options.myConfig.wget.enable = lib.mkEnableOption "wget download tool";
  imports = [ ./wget.nix ];
}
