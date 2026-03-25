function sandbox --description "podman dev containers with Claude Code"
  # Help
  if test "$argv[1]" = "--help"; or test "$argv[1]" = "-h"
    echo "sandbox - sandboxed dev containers with Claude Code"
    echo ""
    echo "  sandbox <name> [dirs...]  create or enter a container"
    echo "                            dirs are mounted as /work/<basename>"
    echo "  sandbox --no-backup       skip project backup on create"
    echo "  sandbox --list            list all containers"
    echo "  sandbox --rm <name>       delete a container"
    echo "  sandbox --rebuild         rebuild the base image"
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
    echo "Usage: sandbox <name> [dirs...]"
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
