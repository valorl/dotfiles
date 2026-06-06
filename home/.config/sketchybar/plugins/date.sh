#!/bin/sh
# datetime="$(date '+%-d.%-m %H:%M')"
sketchybar --set "$NAME" label="$(date '+%a %-d.%-m')" \
    label.color="0xff000000" \
    label.background.color="0xffffffff" \
    label.background.aligh="center" \
    label.background.height="20" \
    label.background.corner_radius="5"
