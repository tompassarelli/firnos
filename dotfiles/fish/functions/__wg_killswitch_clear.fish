function __wg_killswitch_clear
  # Delete by line number in reverse order (so numbers don't shift)
  for linenum in (sudo iptables -L OUTPUT --line-numbers -n | grep "wgon-killswitch" | awk '{print $1}' | sort -rn)
    sudo iptables -D OUTPUT $linenum
  end
end
