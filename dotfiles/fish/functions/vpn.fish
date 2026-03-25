function vpn
  # vpn on / vpn off (default: tokyo)
  # vpn tokyo on / vpn tokyo off
  set -l action
  set -l conf

  if test "$argv[1]" = on -o "$argv[1]" = off
    set action $argv[1]
    set conf wg-tokyo
  else
    set action $argv[2]
    set conf "wg-"(string replace -r '^wg-?' "" -- $argv[1])
  end

  switch "$action"
    case on
      set -l endpoint (grep -oP 'Endpoint\s*=\s*\K[\d.]+' /etc/wireguard/$conf.conf)

      __wg_killswitch_clear

      sudo iptables -I OUTPUT -m comment --comment "wgon-killswitch" -d "$endpoint" -j ACCEPT
      sudo iptables -I OUTPUT -m comment --comment "wgon-killswitch" -d 192.168.0.0/24 -j ACCEPT
      sudo iptables -A OUTPUT -m comment --comment "wgon-killswitch" -j REJECT
      echo "Kill switch enabled"

      sudo wg-quick up "$conf"

    case off
      sudo wg-quick down "$conf"

      __wg_killswitch_clear
      echo "Kill switch disabled"

    case '*'
      echo "vpn [iface] <on|off>  (default iface: tokyo)"
  end
end
