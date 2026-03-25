{ lib, ... }:
{
  options.myConfig.modules.printing.enable = lib.mkEnableOption "CUPS printing service with network discovery";
  imports = [ ./printing.nix ];
}
