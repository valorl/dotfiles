#!/bin/sh

# The $NAME variable is passed from sketchybar and holds the name of
# the item invoking this script:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# label.background.color="0xffa97e6d" \
sketchybar --set "$NAME" label="$(date '+%V')" \
    label.color="0xffffffff" \
    label.background.color="0xffb8002b" \
    label.background.aligh="center" \
    label.background.height="20" \
    label.background.corner_radius="5"
