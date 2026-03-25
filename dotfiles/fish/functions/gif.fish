function gif --description "record screen region to GIF"
  if test (count $argv) -eq 0
    echo "Usage: gif <name> [seconds]"
    return 1
  end
  set -l name $argv[1]
  set -l duration 10
  if test (count $argv) -ge 2
    set duration $argv[2]
  end
  set -l geometry (slurp)
  if test -z "$geometry"
    echo "Error: no region selected"
    return 1
  end
  echo "Recording for $duration seconds..."
  wf-recorder -g "$geometry" -f "$name.mp4" &
  set -l pid $last_pid
  sleep $duration
  kill -INT $pid
  wait $pid 2>/dev/null
  if not test -f "$name.mp4"
    echo "Error: recording failed"
    return 1
  end
  echo "Converting to GIF..."
  ffmpeg -y -i "$name.mp4" -vf "fps=15,scale=800:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" "$name.gif"
  and rm "$name.mp4"
  and echo "Created: $name.gif"
end
