function firn --description "FirnOS config management CLI"
  switch $argv[1]
    case rebuild
      if test (count $argv) -le 1
        sudo nixos-rebuild switch --flake ~/code/nixos-config/
      else
        sudo nixos-rebuild switch --flake ~/code/nixos-config/#$argv[2]
      end
      or return 1
      set -l gen (nixos-rebuild list-generations 2>/dev/null | grep current | string trim | cut -d' ' -f1)
      if test -n "$gen"
        git -C ~/code/nixos-config tag -f "gen-$gen" HEAD 2>/dev/null
        echo "Tagged: gen-$gen"
      end

    case list
      set -l flag ""
      test (count $argv) -ge 2; and set flag $argv[2]
      set -l modules (ls -1 ~/code/nixos-config/modules/)
      set -l bundles (ls -1 ~/code/nixos-config/bundles/)
      set -l hosts_dir ~/code/nixos-config/hosts
      set -l bundles_dir ~/code/nixos-config/bundles

      if test "$flag" = --used
          echo "Used bundles:"
          for b in $bundles
            set -l hosts (rg -l "myConfig\.bundles\.$b\.enable" $hosts_dir 2>/dev/null | sed 's|.*/hosts/||;s|/.*||' | sort -u)
            if test -n "$hosts"
              echo "  $b  ($hosts)"
            end
          end
          echo ""
          echo "Used modules:"
          for m in $modules
            set -l sources
            set -l hosts (rg -l "myConfig\.modules\.$m\.enable" $hosts_dir 2>/dev/null | sed 's|.*/hosts/||;s|/.*||' | sort -u)
            set -l via (rg -l "myConfig\.modules\.$m\.enable" $bundles_dir 2>/dev/null | sed 's|.*/bundles/||;s|/.*||' | sort -u)
            for h in $hosts; set -a sources $h; end
            for v in $via; set -a sources "via $v"; end
            if test (count $sources) -gt 0
              echo "  $m  ("(string join ", " $sources)")"
            end
          end

      else if test "$flag" = --unused
          echo "Unused bundles:"
          for b in $bundles
            set -l used (rg -l "myConfig\.bundles\.$b\.enable" $hosts_dir $bundles_dir 2>/dev/null)
            if test -z "$used"
              echo "  $b"
            end
          end
          echo ""
          echo "Unused modules (not in any host or bundle):"
          for m in $modules
            set -l in_host (rg -l "myConfig\.modules\.$m\.enable" $hosts_dir 2>/dev/null)
            set -l in_bundle (rg -l "myConfig\.modules\.$m\.enable" $bundles_dir 2>/dev/null)
            if test -z "$in_host" -a -z "$in_bundle"
              echo "  $m"
            end
          end

      else
          echo "Bundles ("(count $bundles)"):"
          for b in $bundles
            echo "  myConfig.bundles.$b"
          end
          echo ""
          echo "Modules ("(count $modules)"):"
          for m in $modules
            echo "  myConfig.modules.$m"
          end
      end

    case refs
      if test (count $argv) -le 1
        echo "Usage: firn refs <name>"
        return 1
      end
      set -l name $argv[2]
      echo "Bundles:"
      rg "myConfig\.modules\.$name\.enable" ~/code/nixos-config/bundles/ --files-with-matches 2>/dev/null | sed 's|.*/bundles/||;s|/.*||' | sort -u
      rg "myConfig\.bundles\.$name\.enable" ~/code/nixos-config/bundles/ --files-with-matches 2>/dev/null | sed 's|.*/bundles/||;s|/.*||' | sort -u
      echo ""
      echo "Hosts:"
      rg "myConfig\.modules\.$name\.enable" ~/code/nixos-config/hosts/ --files-with-matches 2>/dev/null | sed 's|.*/hosts/||;s|/.*||' | sort -u
      rg "myConfig\.bundles\.$name\.enable" ~/code/nixos-config/hosts/ --files-with-matches 2>/dev/null | sed 's|.*/hosts/||;s|/.*||' | sort -u

    case mod
      if test (count $argv) -le 1
        echo "Usage: firn mod <name>"
        return 1
      end
      set -l name $argv[2]
      set -l dir ~/code/nixos-config/modules/$name
      if test -d $dir
        echo "Module $name already exists"
        return 1
      end
      mkdir -p $dir
      echo '{ config, lib, pkgs, ... }:
{
  options.myConfig.modules.'$name'.enable = lib.mkEnableOption "'$name'";

  config = lib.mkIf config.myConfig.modules.'$name'.enable {
    # TODO: add configuration
  };
}' > $dir/default.nix
      git -C ~/code/nixos-config add $dir
      echo "Created modules/$name/ (git added)"

    case bundle
      if test (count $argv) -le 2
        echo "Usage: firn bundle <name> <mod1> <mod2> ..."
        return 1
      end
      set -l name $argv[2]
      set -l mods $argv[3..]
      set -l dir ~/code/nixos-config/bundles/$name
      if test -d $dir
        echo "Bundle $name already exists"
        return 1
      end
      mkdir -p $dir
      # default.nix
      set -l opts ""
      for m in $mods
        set opts $opts"    $m.enable = lib.mkOption { type = lib.types.bool; default = true; description = \"Enable $m\"; };\n"
      end
      printf '{ lib, ... }:\n{\n  options.myConfig.bundles.%s = {\n    enable = lib.mkEnableOption "%s";\n%s  };\n\n  imports = [ ./%s.nix ];\n}\n' $name $name $opts $name > $dir/default.nix
      # <name>.nix
      set -l enables ""
      for m in $mods
        set enables $enables"    myConfig.modules.$m.enable = lib.mkDefault cfg.$m.enable;\n"
      end
      printf '{ config, lib, ... }:\n\nlet\n  cfg = config.myConfig.bundles.%s;\nin\n{\n  config = lib.mkIf cfg.enable {\n%s  };\n}\n' $name $enables > $dir/$name.nix
      git -C ~/code/nixos-config add $dir
      echo "Created bundles/$name/ with "(count $mods)" modules (git added)"

    case secret
      set -l subcmd $argv[2]
      set -l repo ~/code/nixos-config
      switch "$subcmd"
        case list
          for f in $repo/secrets/*.yaml
            test -f $f; and basename $f .yaml
          end
        case show
          if test (count $argv) -le 2
            echo "Usage: firn secret show <name>"
            return 1
          end
          set -l file $repo/secrets/$argv[3].yaml
          if not test -f $file
            echo "No secret file: secrets/$argv[3].yaml"
            return 1
          end
          sops -d $file
        case ''
          echo "Usage: firn secret <name|list|show <name>>"
          return 1
        case '*'
          set -l file $repo/secrets/$subcmd.yaml
          sops $file
          if test -f $file
            git -C $repo add $file
            echo "secrets/$subcmd.yaml (git added)"
          end
      end

    case gen
      set -l current (nixos-rebuild list-generations 2>/dev/null | grep current | string trim | cut -d' ' -f1)
      echo "current: $current"
      echo "next:    "(math $current + 1)

    case myfunctions
      myfunctions

    case '*'
      echo "firn <command>"
      echo ""
      echo "  rebuild [host]     nixos-rebuild switch + tag generation"
      echo "  list               list all modules and bundles"
      echo "  list --used        show modules/bundles in use and where"
      echo "  list --unused      show modules/bundles not referenced anywhere"
      echo "  refs <name>        show what references a module/bundle"
      echo "  mod <name>         scaffold a new module"
      echo "  bundle <name> <mods...>  scaffold a new bundle"
      echo "  secret <name>      create/edit an encrypted secret"
      echo "  secret list        list secret files"
      echo "  secret show <name> decrypt and display a secret"
      echo "  gen                show current and next generation numbers"
      echo "  myfunctions        list custom functions and aliases"
  end
end
