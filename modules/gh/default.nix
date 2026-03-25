{ lib, ... }:
{
  options.myConfig.gh.enable = lib.mkEnableOption "GitHub CLI";
  imports = [ ./gh.nix ];
}
