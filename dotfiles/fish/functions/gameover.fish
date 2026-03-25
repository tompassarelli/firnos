function gameover --description "kill all Wine/Proton/gaming processes"
  pkill -9 -f "\.exe" 2>/dev/null
  wineserver -k 2>/dev/null
  echo "Nuked"
end
