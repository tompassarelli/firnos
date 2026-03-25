function opacity
  set -l cfg ~/code/nixos-config/dotfiles/niri/config.kdl
  set -l current (grep -P '^\s+opacity' $cfg | grep -oP '[\d.]+')
  if test (count $argv) -eq 0
    echo "Opacity: $current"
    return
  end
  sed -i "/^[^\/]/s/opacity $current/opacity $argv[1]/" $cfg
  echo "Opacity: $argv[1]"
end
