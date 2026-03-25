function wgoff
  set -l iface (string replace -r '^wg-?' "" -- $argv[1])
  test -z "$iface"; and set iface tokyo
  set -l conf "wg-$iface"

  sudo wg-quick down "$conf"

  # Remove all kill switch rules
  __wg_killswitch_clear
  echo "Kill switch disabled"

  # Stop logging if running
  test -f ~/.wowlog.pids; and wowlogstop
end
