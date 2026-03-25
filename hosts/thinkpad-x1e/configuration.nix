# Host-specific configuration for thinkpad-x1e
#
# NOTE: This host is not actively used. Copy whiterabbit's configuration
# here and customize as needed if this machine comes back into service.
{ lib, ... }:
{
  myConfig.modules.system.stateVersion = "25.05";
  myConfig.modules.boot.enable = true;
  myConfig.modules.users.enable = true;
  myConfig.modules.users.username = "tom";
  myConfig.modules.fish.enable = true;
}
