{ config, lib, pkgs, ... }:

let
  cfg = config.myConfig.modules.framework13-mic;
  username = config.myConfig.modules.users.username;
  firn-mic = pkgs.writeShellApplication {
    name = "firn-mic";
    runtimeInputs = with pkgs; [
      wireplumber
      pipewire
      jq
      python3
      coreutils
      gnugrep
      gawk
      gnused
    ];
    text = builtins.readFile ./firn-mic;
  };
in
{
  options.myConfig.modules.framework13-mic.enable = lib.mkEnableOption "Framework 13 AMD AI 300 mic fix + firn-mic CLI (forces UCM profile that exposes the actual internal mic; see `firn-mic doctor`)";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ firn-mic ];
    services.pipewire.wireplumber.extraConfig = {
      "51-framework13-mic" = {
        "monitor.alsa.rules" = [
          {
            matches = [
              {
                "device.name" = "alsa_card.pci-0000_c1_00.6";
              }
            ];
            actions = {
              update-props = {
                "device.profile" = "HiFi (Mic1, Mic2, Speaker)";
              };
            };
          }
        ];
      };
    };
    systemd.services.firn-mic-alsa-init = {
      description = "Disable Internal Mic Boost on Framework 13 ALC285";
      wantedBy = [ "multi-user.target" ];
      after = [ "sound.target" ];
      path = with pkgs; [ alsa-utils gnugrep gnused coreutils ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        set -eu
        # Find the card index of the ALC285 codec (stable across reboots).
        card=$(grep -l 'Realtek ALC285' /proc/asound/card*/codec* 2>/dev/null \
                | sed -nE 's|.*/card([0-9]+)/.*|\1|p' | head -1)
        if [ -z "$card" ]; then
          echo "firn-mic-alsa-init: ALC285 codec not found, skipping" >&2
          exit 0
        fi
        amixer -c "$card" set 'Internal Mic Boost' 0 >/dev/null
        echo "firn-mic-alsa-init: card$card 'Internal Mic Boost' = 0 dB"
      '';
    };
    home-manager.users.${username} = { config, ... }: {
      systemd.user.services.firn-mic-ensure = {
        Unit = {
          Description = "Pin Framework 13 mic profile and default source";
          After = [ "pipewire.service" "wireplumber.service" ];
          PartOf = [ "pipewire.service" ];
        };
        Service = {
          Type = "oneshot";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
          ExecStart = "${firn-mic}/bin/firn-mic --quiet";
          RemainAfterExit = true;
        };
        Install = {
          WantedBy = [ "pipewire.service" ];
        };
      };
    };
  };
}
