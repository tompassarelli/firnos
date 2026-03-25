function functions --description "fish functions wrapper (--my to list custom)"
  if test "$argv[1]" = "--my"
    for f in ~/code/nixos-config/dotfiles/fish/functions/*.fish
      set -l name (basename $f .fish)
      string match -q '__*' $name; and continue
      string match -q 'functions' $name; and continue
      set -l desc (grep -oP '(?<=--description ").*?(?=")' $f 2>/dev/null)
      printf "  %-16s %s\n" $name "$desc"
    end
  else
    builtin functions $argv
  end
end
