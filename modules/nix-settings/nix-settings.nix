{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.nix-settings;
in
{
  config = lib.mkIf cfg.enable {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      builders-use-substitutes = true;

      # Parallel build settings (maximize CPU usage)
      max-jobs = "auto";  # Auto-detect based on CPU count
      cores = 0;          # Cores per job (0 = use all available)

      # Walker binary caches (avoids building from source)
      extra-substituters = [
        "https://walker.cachix.org"
        "https://walker-git.cachix.org"
      ];
      extra-trusted-public-keys = [
        "walker.cachix.org-1:fG8q+uAaMqhsMxWjwvk0IMb4mFPFLqHjuvfwQxE4oJM="
        "walker-git.cachix.org-1:vmC0ocfPWh0S/vRAQGtChuiZBTAe4wiKDeyyXM0/7pM="
      ];
    };

    # Automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    # TODO: Store optimization (disabled for now - plenty of space)
    # Uncomment to enable automatic hard-linking of duplicate files in /nix/store
    # First run can take 30min-2hrs. Can save 2-10GB typically.
    # Manual run: nix-store --optimise
    # nix.optimise = {
    #   automatic = true;
    #   dates = [ "monthly" ];
    # };

    # Limit number of boot generations (prevents /boot from filling up)
    boot.loader.systemd-boot.configurationLimit = 10;
  };
}
