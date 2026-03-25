{ lib, ... }:
{
  options.myConfig.modules.gh.enable = lib.mkEnableOption "GitHub CLI";
  imports = [ ./gh.nix ];
}
