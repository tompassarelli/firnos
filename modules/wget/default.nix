{ lib, ... }:
{
  options.myConfig.modules.wget.enable = lib.mkEnableOption "wget download tool";
  imports = [ ./wget.nix ];
}
