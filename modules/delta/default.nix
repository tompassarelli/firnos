{ config, lib, pkgs, ... }:

{
  options.myConfig.modules.delta.enable = lib.mkEnableOption "delta git diff viewer";

  config = lib.mkIf config.myConfig.modules.delta.enable {
    environment.systemPackages = [ pkgs.delta ];
  };
}
