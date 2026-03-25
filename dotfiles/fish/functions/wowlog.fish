function wowlog
  if test -f ~/.wowlog.pids
    echo "Logging already running. Run wowlogstop first."
    return 1
  end

  set -l logdir ~/wowlogs/(date +%Y%m%d-%H%M%S)
  mkdir -p $logdir

  # Ping to google DNS (baseline connectivity)
  fish -c "while true; echo (date '+%H:%M:%S') (ping -c1 -W1 8.8.8.8 2>&1 | grep -oP 'time=[\d.]+|100% packet loss'); sleep 1; end" > $logdir/ping-baseline.log 2>&1 &
  set -l pid1 $last_pid

  # Ping to VPN gateway (if VPN interface exists)
  fish -c "while true; set -l gw (ip route show dev wg-tokyo 2>/dev/null | grep -oP '^[\d.]+' | head -1); test -n \"\$gw\"; and echo (date '+%H:%M:%S') (ping -c1 -W1 \$gw 2>&1 | grep -oP 'time=[\d.]+|100% packet loss'); sleep 1; end" > $logdir/ping-vpn.log 2>&1 &
  set -l pid2 $last_pid

  # WireGuard stats every 5s
  fish -c "while true; echo '---' (date '+%H:%M:%S') '---'; sudo wg show wg-tokyo 2>/dev/null || echo 'VPN not up'; sleep 5; end" > $logdir/wg-stats.log 2>&1 &
  set -l pid3 $last_pid

  # Watchdog journal
  journalctl -fu wireguard-watchdog > $logdir/watchdog.log 2>&1 &
  set -l pid4 $last_pid

  # System errors
  journalctl -fp err > $logdir/system-errors.log 2>&1 &
  set -l pid5 $last_pid

  # Save state
  echo $logdir > ~/.wowlog.dir
  echo $pid1 $pid2 $pid3 $pid4 $pid5 > ~/.wowlog.pids

  echo "Logging started: $logdir"
end
