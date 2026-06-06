#!/bin/sh

timezone="$(date '+%Z')"
dst_color=$([ "$timezone" = 'CET' ] && echo "0xff00a6ff" || echo "0xebffb700")

sketchybar --set "$NAME" label="$(TZ="Etc/Utc" date '+%H')" \
    label.color="0xff000000" \
    label.background.color="$dst_color" \
    label.background.align="center" \
    label.background.height="20" \
    label.background.corner_radius="5"
