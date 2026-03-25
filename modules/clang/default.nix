{ lib, ... }:
{
  options.myConfig.modules.clang.enable = lib.mkEnableOption "Clang C/C++ compiler";
  imports = [ ./clang.nix ];
}
