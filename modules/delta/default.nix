{ lib, ... }:
{
  options.myConfig.delta.enable = lib.mkEnableOption "delta git diff viewer";
  imports = [ ./delta.nix ];
}
