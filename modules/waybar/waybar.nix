{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.waybar;
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf cfg.enable {
    # SYSTEM: Install waybar package
    environment.systemPackages = with pkgs; [
      waybar
    ];

    # HOME-MANAGER: User configuration, dotfiles, and services
    home-manager.users.${username} = { config, ... }: {
      # Dotfiles: Main config (self-contained in module)
      xdg.configFile."waybar/config".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/waybar/config";

      # Dotfiles: Stylix-generated CSS (dynamic colors from theme)
      # Note: config.lib.stylix.colors comes from home-manager's stylix integration
      xdg.configFile."waybar/stylix.css".text = with config.lib.stylix.colors; ''
        @define-color base00 #${base00};
        @define-color base01 #${base01};
        @define-color base02 #${base02};
        @define-color base03 #${base03};
        @define-color base04 #${base04};
        @define-color base05 #${base05};
        @define-color base06 #${base06};
        @define-color base07 #${base07};
        @define-color base08 #${base08};
        @define-color base09 #${base09};
        @define-color base0A #${base0A};
        @define-color base0B #${base0B};
        @define-color base0C #${base0C};
        @define-color base0D #${base0D};
        @define-color base0E #${base0E};
        @define-color base0F #${base0F};

        * {
          font-family: "${config.stylix.fonts.monospace.name}";
          font-size: ${toString config.stylix.fonts.sizes.desktop}pt;
        }

        window#waybar, tooltip {
          background: alpha(@base00, ${toString config.stylix.opacity.desktop});
          color: @base05;
        }

        tooltip {
          border-color: @base0D;
        }

        .modules-left #workspaces button {
          border-bottom: 3px solid transparent;
        }
        .modules-left #workspaces button.focused,
        .modules-left #workspaces button.active {
          border-bottom: 3px solid @base05;
        }

        .modules-center #workspaces button {
          border-bottom: 3px solid transparent;
        }
        .modules-center #workspaces button.focused,
        .modules-center #workspaces button.active {
          border-bottom: 3px solid @base05;
        }

        .modules-right #workspaces button {
          border-bottom: 3px solid transparent;
        }
        .modules-right #workspaces button.focused,
        .modules-right #workspaces button.active {
          border-bottom: 3px solid @base05;
        }
      '';

      # Dotfiles: Custom styles (self-contained in module)
      xdg.configFile."waybar/style.css".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/waybar/style.css";

      # Dotfiles: Overview script (self-contained in module)
      xdg.configFile."waybar/overview-waybar.py".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/waybar/overview-waybar.py";

      # Systemd service: Main waybar daemon
      systemd.user.services.waybar = {
        Unit = {
          Description = "Highly customizable Wayland bar";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" "xdg-desktop-portal.service" ];
          Requisite = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.waybar}/bin/waybar";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "niri.service" ];
        };
      };

      # Systemd service: Overview listener script
      systemd.user.services.waybar-overview = {
        Unit = {
          Description = "Waybar overview listener script";
          PartOf = [ "graphical-session.target" ];
          After = [ "waybar.service" ];
          Requires = [ "waybar.service" ];
        };
        Service = {
          ExecStart = "%h/.config/waybar/overview-waybar.py";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "niri.service" ];
        };
      };
    };
  };
}
