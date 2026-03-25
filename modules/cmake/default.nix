{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.cmake.enable = lib.mkEnableOption "CMake build system";

  config = lib.mkIf config.myConfig.modules.cmake.enable {
    environment.systemPackages = [ pkgs.cmake ];
  };
}
