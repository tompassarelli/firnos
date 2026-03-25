{ config, lib, pkgs, ... }:
let
  username = config.myConfig.users.username;
in
{
  config = lib.mkIf config.myConfig.fish.enable {
    # ============ SYSTEM-LEVEL CONFIGURATION ============

    # Enable fish shell system-wide
    programs.fish.enable = true;

    # ============ HOME-MANAGER CONFIGURATION ============

    home-manager.users.${username} = {
      # Fish shell configuration
      programs.fish = {
        enable = true;
        shellAliases = {
          # modern utils
          du = "dust";
          ls = "eza";
          ps = "procs";
          vim = "nvim"; # keep vi as fallback
          v = "nvim";
          # emacs client (connect to daemon for fast startup)
          e = "emacsclient -t -a emacs";  # terminal emacs
          eg = "emacsclient -n -c -a emacs";  # GUI emacs (-n = no-wait, -c = new frame)
          # shorthands
          gits = "git status";
          gitd = "git diff";
          gitdc = "git diff --cached";
          gita = "git add -v . && git status";
          gitp = "git push";
        };
        interactiveShellInit = ''
          # Change to default directory (skip in Emacs vterm)
          if not set -q INSIDE_EMACS
            cd ~
          end

          # NixOS rebuild with optional config argument
          function rebuild
            if test (count $argv) -eq 0
              sudo nixos-rebuild switch --flake ~/code/nixos-config/
            else
              sudo nixos-rebuild switch --flake ~/code/nixos-config/#$argv[1]
            end
          end

          # Git commit with neovim in insert mode
          function gitc
            GIT_EDITOR="nvim -c 'startinsert'" git commit
          end

          # Copy file contents to clipboard
          function wlc
            if test -f "$argv[1]"
              cat "$argv[1]" | wl-copy
              echo "Copied $argv[1] to clipboard"
            else
              echo "Error: File not found: $argv[1]"
              return 1
            end
          end

          # Move most recent screenshot to current directory
          function movess
            set -l files ~/Pictures/Screenshots/*.png
            if test (count $files) -eq 0
              echo "No screenshots found"
              return 1
            end
            set -l newest $files[1]
            for file in $files
              test $file -nt $newest; and set newest $file
            end
            set -l ext (string match -r '\.[^.]+$' $newest)
            set -l name (basename $newest)
            mv $newest ./screenshot$ext
            echo "Moved: $name → ./screenshot$ext"
          end

          # Record screen region and convert to GIF
          # Usage: gif <name> [seconds]  (default: 10s)
          function gif
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

          # === Gaming session logging ===
          # Standalone logger - can be used with or without VPN
          function wowlog
            if test -f ~/.wowlog.pids
              echo "Logging already running. Run wowlogstop first."
              return 1
            end

            set -l logdir ~/wowlogs/(date +%Y%m%d-%H%M%S)
            mkdir -p ''$logdir

            # Ping to google DNS (baseline connectivity)
            fish -c "while true; echo (date '+%H:%M:%S') (ping -c1 -W1 8.8.8.8 2>&1 | grep -oP 'time=[\d.]+|100% packet loss'); sleep 1; end" > ''$logdir/ping-baseline.log 2>&1 &
            set -l pid1 ''$last_pid

            # Ping to VPN gateway (if VPN interface exists)
            fish -c "while true; set -l gw (ip route show dev wg-tokyo 2>/dev/null | grep -oP '^[\d.]+' | head -1); test -n \"''$gw\"; and echo (date '+%H:%M:%S') (ping -c1 -W1 ''$gw 2>&1 | grep -oP 'time=[\d.]+|100% packet loss'); sleep 1; end" > ''$logdir/ping-vpn.log 2>&1 &
            set -l pid2 ''$last_pid

            # WireGuard stats every 5s
            fish -c "while true; echo '---' (date '+%H:%M:%S') '---'; sudo wg show wg-tokyo 2>/dev/null || echo 'VPN not up'; sleep 5; end" > ''$logdir/wg-stats.log 2>&1 &
            set -l pid3 ''$last_pid

            # Watchdog journal
            journalctl -fu wireguard-watchdog > ''$logdir/watchdog.log 2>&1 &
            set -l pid4 ''$last_pid

            # System errors
            journalctl -fp err > ''$logdir/system-errors.log 2>&1 &
            set -l pid5 ''$last_pid

            # Save state
            echo ''$logdir > ~/.wowlog.dir
            echo ''$pid1 ''$pid2 ''$pid3 ''$pid4 ''$pid5 > ~/.wowlog.pids

            echo "Logging started: ''$logdir"
          end

          function wowlogstop
            if not test -f ~/.wowlog.pids
              echo "No logging session running"
              return 1
            end

            # Kill logging processes
            for pid in (cat ~/.wowlog.pids)
              kill ''$pid 2>/dev/null
            end

            set -l logdir (cat ~/.wowlog.dir)
            set -l wowdir "$HOME/.steam/steam/steamapps/compatdata/3983253308/pfx/drive_c/Program Files (x86)/World of Warcraft/_classic_era_"

            # Snapshot WoW logs
            mkdir -p ''$logdir/wow
            cp "''$wowdir/Logs/"*.log ''$logdir/wow/ 2>/dev/null
            cp "''$wowdir/WTF/Account/"*/SavedVariables/\!BugGrabber.lua ''$logdir/wow/ 2>/dev/null

            rm -f ~/.wowlog.pids ~/.wowlog.dir

            echo "Logging stopped: ''$logdir"
            echo "WoW logs archived to ''$logdir/wow/"
          end

          # === WireGuard session management ===
          # Helper: remove all kill switch rules (tagged with comment)
          function __wg_killswitch_clear
            # Delete by line number in reverse order (so numbers don't shift)
            for linenum in (sudo iptables -L OUTPUT --line-numbers -n | grep "wgon-killswitch" | awk '{print $1}' | sort -rn)
              sudo iptables -D OUTPUT ''$linenum
            end
          end

          # Usage: wgon tokyo | wgon wg-tokyo | wgon (defaults to tokyo)
          function wgon
            set -l iface (string replace -r '^wg-?' "" -- ''$argv[1])
            test -z "''$iface"; and set iface tokyo
            set -l conf "wg-''$iface"
            set -l endpoint (grep -oP 'Endpoint\s*=\s*\K[\d.]+' /etc/wireguard/''$conf.conf)

            # Start logging
            wowlog

            # Clear any existing kill switch rules first (idempotent)
            __wg_killswitch_clear

            # Kill switch: block all traffic except to VPN endpoint and LAN
            sudo iptables -I OUTPUT -m comment --comment "wgon-killswitch" -d "''$endpoint" -j ACCEPT
            sudo iptables -I OUTPUT -m comment --comment "wgon-killswitch" -d 192.168.0.0/24 -j ACCEPT
            sudo iptables -A OUTPUT -m comment --comment "wgon-killswitch" -j REJECT
            echo "Kill switch enabled"

            sudo wg-quick up "''$conf"
          end

          function wgoff
            set -l iface (string replace -r '^wg-?' "" -- ''$argv[1])
            test -z "''$iface"; and set iface tokyo
            set -l conf "wg-''$iface"

            sudo wg-quick down "''$conf"

            # Remove all kill switch rules
            __wg_killswitch_clear
            echo "Kill switch disabled"

            # Stop logging if running
            test -f ~/.wowlog.pids; and wowlogstop
          end

          # Kill all Wine/Proton/gaming processes
          function killgames
            pkill -9 -f "\.exe" 2>/dev/null
            wineserver -k 2>/dev/null
            echo "Nuked"
          end

          # Create or enter a named dev container
          # Usage: makedev <name>          - create new or enter existing
          #        makedev --list          - list all dev containers
          #        makedev --rm <name>     - delete a container
          #        makedev --rebuild       - rebuild the base image
          function makedev
            # Help
            if test "$argv[1]" = "--help"; or test "$argv[1]" = "-h"
              echo "makedev - sandboxed dev containers with Claude Code"
              echo ""
              echo "  makedev <name> [dirs...]  create or enter a container"
              echo "                            dirs are mounted as /work/<basename>"
              echo "  makedev --no-backup       skip project backup on create"
              echo "  makedev --list            list all containers"
              echo "  makedev --rm <name>       delete a container"
              echo "  makedev --rebuild         rebuild the base image"
              return
            end

            # Rebuild base image
            if test "$argv[1]" = "--rebuild"
              echo "Building claude-sandbox..."
              nix build ~/code/nixos-config#claude-sandbox --out-link ~/code/nixos-config/builds/claude-sandbox
              and echo "Loading into podman..."
              and podman load < ~/code/nixos-config/builds/claude-sandbox
              and echo "Done."
              return
            end

            # List containers
            if test "$argv[1]" = "--list"
              podman ps -a --filter "label=makedev" --format "{{.Names}}\t{{.Status}}"
              return
            end

            # Remove container
            if test "$argv[1]" = "--rm"
              podman rm -f "dev-$argv[2]"
              rm -rf ~/.local/share/makedev/$argv[2]
              return
            end

            # Parse flags
            set -l nobackup false
            set -l args
            for arg in $argv
              if test "$arg" = "--no-backup"
                set nobackup true
              else
                set args $args $arg
              end
            end

            # Require a name
            if test (count $args) -eq 0
              echo "Usage: makedev <name> [dirs...]"
              return 1
            end

            set -l name "dev-$args[1]"
            set -l dirs $args[2..]

            # Build image if missing
            if not podman image exists claude-sandbox:latest
              echo "Building claude-sandbox..."
              nix build ~/code/nixos-config#claude-sandbox --out-link ~/code/nixos-config/builds/claude-sandbox
              and echo "Loading into podman..."
              and podman load < ~/code/nixos-config/builds/claude-sandbox
              or return 1
            end

            # If container exists, just enter it
            if podman container exists $name
              podman start -ai $name
              return
            end

            # Set up claude credentials (only on first create)
            set -l datadir ~/.local/share/makedev/$args[1]
            if not test -d $datadir/.claude
              mkdir -p $datadir
              cp -rL --no-preserve=mode ~/.claude/ $datadir/.claude/
              cp ~/.claude.json $datadir/.claude.json
              chmod -R a+rw $datadir/.claude $datadir/.claude.json
              # Pre-trust /work so Claude Code skips the trust dialog
              python3 -c "
import json, sys
f = sys.argv[1]
d = json.load(open(f))
d.setdefault(\"projects\", {})[\"/work\"] = {\"allowedTools\": [], \"hasTrustDialogAccepted\": True}
json.dump(d, open(f, \"w\"), indent=2)
" $datadir/.claude.json
            end
            # Backup projects before mounting
            if test "$nobackup" = false
              set -l backupdir $datadir/backups/(date +%Y%m%d-%H%M%S)
              mkdir -p $backupdir
              if test (count $dirs) -gt 0
                for dir in $dirs
                  set -l absdir (realpath $dir)
                  set -l base (basename $absdir)
                  cp -r $absdir $backupdir/$base
                end
              else
                cp -r (pwd) $backupdir/(basename (pwd))
              end
              echo "Backup: $backupdir"
            end

            # Build volume args
            set -l vols \
              -v $datadir/.claude:/home/dev/.claude \
              -v $datadir/.claude.json:/home/dev/.claude.json

            if test (count $dirs) -gt 0
              for dir in $dirs
                set -l absdir (realpath $dir)
                set -l base (basename $absdir)
                set vols $vols -v $absdir:/work/$base
              end
            else
              set vols $vols -v (pwd):/work
            end

            podman create -it \
              --name $name \
              --label makedev \
              --userns=keep-id \
              $vols \
              claude-sandbox:latest
            podman start -ai $name
          end

          # Set niri global opacity (e.g. niri-opacity 0.92)
          function niri-opacity
            set -l cfg ~/code/nixos-config/dotfiles/niri/config.kdl
            set -l current (grep -P '^\s+opacity' $cfg | grep -oP '[\d.]+')
            if test (count $argv) -eq 0
              echo "Opacity: $current"
              return
            end
            sed -i "/^[^\/]/s/opacity $current/opacity $argv[1]/" $cfg
            echo "Opacity: $argv[1]"
          end

          # Show current and next NixOS generation numbers
          function nixgen
            set current (nixos-rebuild list-generations | grep current | cut -d' ' -f1)
            echo "current: $current"
            echo "next:    "(math $current + 1)
          end
        '';
      };

    };
  };
}
