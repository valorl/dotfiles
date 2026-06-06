#!/bin/sh

CHARGING="$(pmset -g batt | grep 'AC Power')"
PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"

if [ "$CHARGING" != "" ]; then
    icon="󰠠"
elif [ "$PERCENTAGE" != "" ]
    case "${PERCENTAGE}" in
        [0-9])
            icon="󰁺"
            ;;
        [1-2][0-9])
            color="0xff000000"
            background_color="0xffff1900"
            background_drawing="on"
            ;;
        *)
            color="0xffffffff"
            background_drawing="off"
            ;;
    esac
fi

# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" \
    label.drawing="off" \
    icon="$icon" \
    icon.font.size="20" \
    icon.drawing="on" \
    icon.color="0xff00ff00" \
    icon.padding_right="0" \
    icon.padding_left="0" \
    padding_right="0" \
    padding_left="0" \
