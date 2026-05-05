{ lib, ... }:

{
  myConfig.modules.system.stateVersion = "25.05";
  myConfig.modules.boot.enable = true;
  myConfig.modules.users.enable = true;
  myConfig.modules.users.username = "tom";
  myConfig.modules.fish.enable = true;
}
