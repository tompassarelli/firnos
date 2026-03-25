function commands --description "list custom fish functions"
  for f in ~/code/nixos-config/dotfiles/fish/functions/*.fish
    set -l name (basename $f .fish)
    string match -q '__*' $name; and continue
    string match -q 'commands' $name; and continue
    set -l desc (functions -D -v $name 2>/dev/null | head -1)
    # fallback: parse --description from file if function not yet loaded
    if test -z "$desc" -o "$desc" = $name
      set desc (grep -oP '(?<=--description ").*?(?=")' $f 2>/dev/null)
    end
    printf "  %-16s %s\n" $name "$desc"
  end
end
