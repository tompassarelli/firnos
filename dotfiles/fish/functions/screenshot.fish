function screenshot --description "path to latest screenshot, sets \$SCREENSHOT"
  set -l files ~/Pictures/Screenshots/*.png
  if test (count $files) -eq 0
    echo "No screenshots found"
    return 1
  end
  set -l newest $files[1]
  for file in $files
    test $file -nt $newest; and set newest $file
  end
  set -gx SCREENSHOT $newest
  echo $newest
end
