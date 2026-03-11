#!/usr/bin/env bash
# Battery script for ironbar - outputs nerd font icon + percentage

pct=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -1)
ac=$(cat /sys/class/power_supply/AC*/online 2>/dev/null || cat /sys/class/power_supply/ADP*/online 2>/dev/null)

if [[ -z "$pct" ]]; then
    echo "󰂑 --"
    exit 0
fi

# Pick icon based on charge level
if (( pct >= 90 )); then
    icon="󰁹"
elif (( pct >= 70 )); then
    icon="󰂀"
elif (( pct >= 50 )); then
    icon="󰁾"
elif (( pct >= 30 )); then
    icon="󰁼"
elif (( pct >= 10 )); then
    icon="󰁻"
else
    icon="󰂃"
fi

# Show output
if [[ "$status" == "Charging" ]]; then
    echo "󰂄 $pct%"
elif [[ "$ac" == "1" ]]; then
    echo "󰚥 $pct%"
else
    echo "$icon $pct%"
fi
