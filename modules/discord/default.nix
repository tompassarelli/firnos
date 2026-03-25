{ lib, ... }:
{
  options.myConfig.modules.discord.enable = lib.mkEnableOption "Discord chat client";
  imports = [ ./discord.nix ];
}
