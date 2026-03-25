{ lib, ... }:
{
  options.myConfig.modules.delta.enable = lib.mkEnableOption "delta git diff viewer";
  imports = [ ./delta.nix ];
}
