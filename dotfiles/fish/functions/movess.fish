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
