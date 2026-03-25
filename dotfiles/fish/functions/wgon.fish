function wgon
  set -l iface (string replace -r '^wg-?' "" -- $argv[1])
  test -z "$iface"; and set iface tokyo
  set -l conf "wg-$iface"
  set -l endpoint (grep -oP 'Endpoint\s*=\s*\K[\d.]+' /etc/wireguard/$conf.conf)

  # Start logging
  wowlog

  # Clear any existing kill switch rules first (idempotent)
  __wg_killswitch_clear

  # Kill switch: block all traffic except to VPN endpoint and LAN
  sudo iptables -I OUTPUT -m comment --comment "wgon-killswitch" -d "$endpoint" -j ACCEPT
  sudo iptables -I OUTPUT -m comment --comment "wgon-killswitch" -d 192.168.0.0/24 -j ACCEPT
  sudo iptables -A OUTPUT -m comment --comment "wgon-killswitch" -j REJECT
  echo "Kill switch enabled"

  sudo wg-quick up "$conf"
end
