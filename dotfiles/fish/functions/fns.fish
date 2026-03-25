function fns --description "list custom functions and aliases"
  echo "Functions:"
  for f in ~/code/nixos-config/dotfiles/fish/functions/*.fish
    set -l name (basename $f .fish)
    string match -q '__*' $name; and continue
    string match -q 'fns' $name; and continue
    set -l desc (grep -oP '(?<=--description ").*?(?=")' $f 2>/dev/null)
    printf "  %-16s %s\n" $name "$desc"
  end
  echo ""
  echo "Aliases:"
  for pair in \
    "du            dust" \
    "ls            eza" \
    "ps            procs" \
    "v             nvim" \
    "e             emacsclient (terminal)" \
    "eg            emacsclient (GUI)" \
    "gits          git status" \
    "gitd          git diff" \
    "gitdc         git diff --cached" \
    "gita          git add -v . && git status" \
    "gitp          git push"
    printf "  %s\n" $pair
  end
end
