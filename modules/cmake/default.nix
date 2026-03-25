{ lib, ... }:
{
  options.myConfig.cmake.enable = lib.mkEnableOption "CMake build system";
  imports = [ ./cmake.nix ];
}
