{ lib, ... }:
{
  options.myConfig.discord.enable = lib.mkEnableOption "Discord chat client";
  imports = [ ./discord.nix ];
}
