{ lib, ... }:
{
  options.myConfig.modules.cmake.enable = lib.mkEnableOption "CMake build system";
  imports = [ ./cmake.nix ];
}
