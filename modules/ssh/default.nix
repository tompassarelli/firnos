{ config, lib, ... }:
{ "config" = (lib."mkIf" (config."myConfig"."modules"."ssh"."enable") ({ "services" = { "openssh" = { "enable" = true; }; }; })); "options" = { "myConfig" = { "modules" = { "ssh" = { "enable" = (lib."mkEnableOption" ("SSH server")); }; }; }; }; }
