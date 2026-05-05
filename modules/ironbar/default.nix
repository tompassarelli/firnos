{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.ironbar;
  username = config.myConfig.modules.users.username;
in
{
  options.myConfig.modules.ironbar.enable = lib.mkEnableOption "Ironbar status bar for Wayland";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.unstable.ironbar ];
    home-manager.users.${username} = { config, ... }: {
      xdg.configFile."ironbar/config.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/ironbar/config.toml";
      xdg.configFile."ironbar/stylix.css".text = with config.lib.stylix.colors; ''
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
        
        .background {
          background: alpha(@base00, ${toString config.stylix.opacity.desktop});
          color: @base05;
        }
        
        tooltip {
          background: alpha(@base00, ${toString config.stylix.opacity.desktop});
          color: @base05;
          border-color: @base0D;
        }
      '';
      xdg.configFile."ironbar/style.css".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/ironbar/style.css";
      xdg.configFile."ironbar/overview-ironbar.py".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/ironbar/overview-ironbar.py";
      xdg.configFile."ironbar/battery.sh".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/nixos-config/dotfiles/ironbar/battery.sh";
      systemd.user.services.ironbar = {
        Unit = {
          Description = "Customizable GTK4 status bar for Wayland";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.unstable.ironbar}/bin/ironbar";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "niri.service" ];
        };
      };
      systemd.user.services.ironbar-overview = {
        Unit = {
          Description = "Ironbar overview listener script";
          PartOf = [ "graphical-session.target" ];
          After = [ "ironbar.service" ];
          Requires = [ "ironbar.service" ];
        };
        Service = {
          ExecStart = "%h/.config/ironbar/overview-ironbar.py";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "niri.service" ];
        };
      };
    };
  };
}
