{ lib, ... }:
{
  options.myConfig.clang.enable = lib.mkEnableOption "Clang C/C++ compiler";
  imports = [ ./clang.nix ];
}
