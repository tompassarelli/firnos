function wowlogstop
  if not test -f ~/.wowlog.pids
    echo "No logging session running"
    return 1
  end

  # Kill logging processes
  for pid in (cat ~/.wowlog.pids)
    kill $pid 2>/dev/null
  end

  set -l logdir (cat ~/.wowlog.dir)
  set -l wowdir "$HOME/.steam/steam/steamapps/compatdata/3983253308/pfx/drive_c/Program Files (x86)/World of Warcraft/_classic_era_"

  # Snapshot WoW logs
  mkdir -p $logdir/wow
  cp "$wowdir/Logs/"*.log $logdir/wow/ 2>/dev/null
  cp "$wowdir/WTF/Account/"*/SavedVariables/\!BugGrabber.lua $logdir/wow/ 2>/dev/null

  rm -f ~/.wowlog.pids ~/.wowlog.dir

  echo "Logging stopped: $logdir"
  echo "WoW logs archived to $logdir/wow/"
end
