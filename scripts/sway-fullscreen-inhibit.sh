#!/bin/bash

# Automatically inhibits swayidle when any window enters fullscreen.


# Configuration
TIMER_NAME="${1:-idle_timer}"  
POLL_INTERVAL=2               
STATE_TRACKER="active"       

# Graceful cleanup: resume timer if script is killed while inhibited
cleanup() {
    [[ "$STATE_TRACKER" == "inhibited" ]] && swaymsg idle resume "$TIMER_NAME" 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM

# Check if any window is currently fullscreen (mode 1 = fullscreen, 2 = fullscreen+maximized)
has_fullscreen() {
    swaymsg -t get_tree 2>/dev/null | grep -q '"fullscreen_mode": *[12]'
}

while true; do
    if has_fullscreen && [[ "$STATE_TRACKER" == "active" ]]; then
        swaymsg idle inhibit "$TIMER_NAME" 2>/dev/null
        STATE_TRACKER="inhibited"
    elif ! has_fullscreen && [[ "$STATE_TRACKER" == "inhibited" ]]; then
        swaymsg idle resume "$TIMER_NAME" 2>/dev/null
        STATE_TRACKER="active"
    fi
    sleep "$POLL_INTERVAL"
done
