{ lib, ... }:

{
  myConfig.modules.users.username = "ashashi";
  myConfig.bundles.terminal.enable = true;
  myConfig.bundles.cli-tools.enable = true;
  myConfig.bundles.development.enable = true;
}
