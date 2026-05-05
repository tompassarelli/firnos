#lang nisp

(module-file modules wireguard
  (desc "WireGuard VPN support")
  (lets ([username 'config.myConfig.modules.users.username]))
  (config-body
    ;; Allow user to run wg show without password (for logging)
    (set security.sudo.extraRules
      (lst (att (users (lst 'username))
                (commands
                  (lst (att (command (s "${pkgs.wireguard-tools}/bin/wg"))
                            (options (lst "NOPASSWD"))))))))

    (set networking.firewall.checkReversePath "loose") ;; Required for WireGuard
    (set services.resolved.enable #t)                  ;; Required for wg-quick DNS
    ;; Config files go in /etc/wireguard/ - use: sudo wg-quick up wg0

    ;; WireGuard watchdog - detects dead connections and forces re-handshake within ~2 seconds
    (set systemd.services.wireguard-watchdog
      (att (description "WireGuard connection watchdog")
           (after (lst "network.target"))
           (serviceConfig
             (att (Type "simple")
                  (Restart "always")
                  (RestartSec 5)
                  (ExecStart
                    (let-in
                      ([watchdog
                        (call 'pkgs.writeShellScript "wg-watchdog"
                              (ms "export PATH=\"${lib.makeBinPath [ pkgs.wireguard-tools pkgs.iputils pkgs.gawk pkgs.coreutils ]}:$PATH\""
                                  ""
                                  "MISS_COUNT=0"
                                  "MISS_THRESHOLD=5"
                                  ""
                                  "while true; do"
                                  "  IFACE=$(wg show interfaces 2>/dev/null | head -1)"
                                  ""
                                  "  if [ -z \"$IFACE\" ]; then"
                                  "    sleep 5"
                                  "    continue"
                                  "  fi"
                                  ""
                                  "  # Get gateway IP from the interface (first IP in allowed-ips, usually the VPN gateway)"
                                  "  GATEWAY=$(ip route show dev \"$IFACE\" 2>/dev/null | grep -oP '^\\d+\\.\\d+\\.\\d+\\.\\d+' | head -1)"
                                  "  if [ -z \"$GATEWAY\" ]; then"
                                  "    GATEWAY=\"10.100.0.1\"  # fallback"
                                  "  fi"
                                  ""
                                  "  if ! ping -c 1 -W 1 -I \"$IFACE\" \"$GATEWAY\" >/dev/null 2>&1; then"
                                  "    MISS_COUNT=$((MISS_COUNT + 1))"
                                  "    echo \"$(date): Ping miss $MISS_COUNT/$MISS_THRESHOLD on $IFACE\""
                                  ""
                                  "    if [ $MISS_COUNT -ge $MISS_THRESHOLD ]; then"
                                  "      echo \"$(date): Connection dead on $IFACE, full restart\""
                                  ""
                                  "      # Full teardown and recreate - new source port, fresh state"
                                  "      wg-quick down \"$IFACE\" 2>/dev/null"
                                  "      sleep 1"
                                  "      wg-quick up \"$IFACE\""
                                  "      echo \"$(date): Interface $IFACE restarted\""
                                  ""
                                  "      MISS_COUNT=0"
                                  "      sleep 3"
                                  "    fi"
                                  "  else"
                                  "    MISS_COUNT=0"
                                  "  fi"
                                  ""
                                  "  sleep 1"
                                  "done"))])
                      (s watchdog)))))
           (wantedBy (lst "multi-user.target"))))

    (set environment.systemPackages (with-pkgs wireguard-tools))))
