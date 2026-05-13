#lang nisp

;; Framework 13 AMD AI 300 microphone fix.
;;
;; The Realtek ALC285 codec on this hardware exposes its mic pins as a set of
;; UCM profiles. The default WirePlumber-selected profile, "HiFi (Headset,
;; Mic1, Speaker)", maps to:
;;   [In] Headset = 3.5mm jack mic (silent unless something is plugged in)
;;   [In] Mic1    = unconnected pin on this hardware → records pure silence
;; The actual built-in laptop mic is on the codec's "Mic2" pin, only exposed
;; in profiles "HiFi (Mic1, Mic2, Speaker)" or "HiFi (Headphones, Mic1, Mic2)".
;;
;; Three-layer fix:
;;   1. WirePlumber rule biases policy at device-creation time.
;;   2. System-level `firn-mic-alsa-init.service` runs on boot to disable the
;;      codec's "Internal Mic Boost" (+10 dB analog gain stage that rail-clips
;;      the ADC on ambient noise). Brings the input to a clean baseline before
;;      any user-level volume work happens.
;;   3. systemd-user `firn-mic-ensure.service` re-applies on every login,
;;      pinning the right UCM profile and Mic2 as default. Volume gets reset
;;      to 0.40 (perceptual) only if it's at the unconfigured 1.00 sentinel —
;;      manual `wpctl set-volume` / pavucontrol adjustments persist.
;;
;; Helper CLI: `firn-mic` — see `firn-mic doctor` for the full story.

(module-file modules framework13-mic
  (desc "Framework 13 AMD AI 300 mic fix + firn-mic CLI (forces UCM profile that exposes the actual internal mic; see `firn-mic doctor`)")
  (lets ([username config.myConfig.modules.users.username]
         [firn-mic
          (call pkgs.writeShellApplication
            (att (name "firn-mic")
                 (runtimeInputs
                   (with-pkgs wireplumber pipewire jq python3 coreutils
                              gnugrep gawk gnused))
                 (text (call builtins.readFile (p "./firn-mic"))))) ]))
  (config-body
    ;; Install the CLI system-wide.
    (set environment.systemPackages (lst firn-mic))

    ;; WirePlumber config: bias profile selection on the ALC285 card to one
    ;; that exposes Mic2. Match by device.name (stable PCI BDF), not by
    ;; object.path (which uses non-stable enumeration like "alsa:acp:Generic_1").
    ;;
    ;; Note: the "\"foo.bar\"" wrapping forces nisp to emit a literal quoted
    ;; attr name instead of splitting on dot — WirePlumber wants flat keys
    ;; with dots ("monitor.alsa.rules": [...]), not nested attrs.
    (set services.pipewire.wireplumber.extraConfig
      (att ("\"51-framework13-mic\""
             (att ("\"monitor.alsa.rules\""
                    (lst (att (matches (lst (att ("\"device.name\"" "alsa_card.pci-0000_c1_00.6"))))
                              (actions (att (update-props
                                              (att ("\"device.profile\"" "HiFi (Mic1, Mic2, Speaker)"))))))))))))

    ;; System-level oneshot: disable the ALC285's "Internal Mic Boost" on every
    ;; boot. The boost is a +10 dB analog gain stage *before* the ADC; with it
    ;; on, ambient room noise rail-clips the digital signal regardless of
    ;; WirePlumber-level attenuation. amixer state survives normally, but is
    ;; not guaranteed across kernel module reloads or some power-state events.
    ;; Card index isn't stable across kernel boots, so resolve by codec match.
    (set systemd.services.firn-mic-alsa-init
      (att (description "Disable Internal Mic Boost on Framework 13 ALC285")
           (wantedBy (lst "multi-user.target"))
           (after (lst "sound.target"))
           (path (with-pkgs alsa-utils gnugrep gnused coreutils))
           (serviceConfig
             (att (Type "oneshot")
                  (RemainAfterExit #t)))
           (script
             (ms "set -eu"
                 "# Find the card index of the ALC285 codec (stable across reboots)."
                 "card=$(grep -l 'Realtek ALC285' /proc/asound/card*/codec* 2>/dev/null \\"
                 "        | sed -nE 's|.*/card([0-9]+)/.*|\\1|p' | head -1)"
                 "if [ -z \"$card\" ]; then"
                 "  echo \"firn-mic-alsa-init: ALC285 codec not found, skipping\" >&2"
                 "  exit 0"
                 "fi"
                 "amixer -c \"$card\" set 'Internal Mic Boost' 0 >/dev/null"
                 "echo \"firn-mic-alsa-init: card$card 'Internal Mic Boost' = 0 dB\""))))

    ;; Systemd-user oneshot: re-applies the user-facing fix on every session
    ;; start. Guards against:
    ;;   - WirePlumber state drift (e.g. some app changing default-source).
    ;;   - The WirePlumber config rule above being a no-op on future WP versions.
    ;;   - Headphones being unplugged at boot (jack-detection then changes
    ;;     profile availability; ensure picks the right one for current state).
    (home-of username
      (set systemd.user.services.firn-mic-ensure
        (att (Unit
               (att (Description "Pin Framework 13 mic profile and default source")
                    (After (lst "pipewire.service" "wireplumber.service"))
                    (PartOf (lst "pipewire.service"))))
             (Service
               (att (Type "oneshot")
                    ;; Brief sleep gives WirePlumber time to enumerate cards.
                    (ExecStartPre (s "${pkgs.coreutils}/bin/sleep 2"))
                    (ExecStart (s "${firn-mic}/bin/firn-mic --quiet"))
                    (RemainAfterExit #t)))
             (Install
               (att (WantedBy (lst "pipewire.service")))))))))
