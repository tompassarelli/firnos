{ config, lib, pkgs, ... }:

let
  # Racket packages installed via raco (not available as nix derivations).
  # These get installed into ~/.local/share/racket/ per-user.
  racoPackages = [
    "drracket-vim-tool"
    "db"
  ];

  racoEnsure = pkgs.writeShellScript "raco-ensure-packages" ''
    for pkg in ${lib.concatStringsSep " " racoPackages}; do
      if ! ${pkgs.racket}/bin/raco pkg show "$pkg" 2>/dev/null | grep -q "Package name:"; then
        ${pkgs.racket}/bin/raco pkg install --auto --skip-installed "$pkg"
      fi
    done
  '';
in
{
  options.myConfig.modules.drracket.enable = lib.mkEnableOption "DrRacket IDE";

  config = lib.mkIf config.myConfig.modules.drracket.enable {
    environment.systemPackages = [ pkgs.racket ];

    # Ensure raco packages are installed on activation
    system.activationScripts.racoPackages.text = ''
      sudo -u ${config.myConfig.modules.users.username} ${racoEnsure} || true
    '';
  };
}
