# Host-specific configuration for thinkpad-x1e
#
# NOTE: This host is not actively used. Copy whiterabbit's configuration
# here and customize as needed if this machine comes back into service.
{ lib, ... }:
{
  myConfig.system.stateVersion = "25.05";
  myConfig.boot.enable = true;
  myConfig.users.enable = true;
  myConfig.users.username = "tom";
  myConfig.fish.enable = true;
}
