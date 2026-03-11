{ config, lib, pkgs, flakeRoot, ... }:
let
  username = config.myConfig.users.username;
  settingsBase = {
    vim_mode = true;
    ui_font_size = 16;
    buffer_font_size = 16;
    theme = {
      mode = "system";
      light = "One Dark";
      dark = "One Dark";
    };
    context_servers = {
      postgres-context-server = {
        source = "extension";
        enabled = true;
        settings = {
          database_url = config.sops.placeholder."zed-db-url";
        };
      };
    };
  };
in
{
  config = lib.mkIf config.myConfig.zed.enable {
    environment.systemPackages = with pkgs; [
      unstable.zed-editor
    ];

    sops.secrets."zed-db-url" = {
      sopsFile = flakeRoot + "/secrets/zed.yaml";
    };

    sops.templates."zed-settings" = {
      content = builtins.toJSON settingsBase;
      owner = username;
    };

    home-manager.users.${username} = { config, ... }: {
      home.file.".config/zed/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink "/run/secrets-rendered/zed-settings";
    };
  };
}
