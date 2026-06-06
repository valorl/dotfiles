#!/bin/sh

CHARGING="$(pmset -g batt | grep 'AC Power')"
PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"

background_drawing="off"

if [ "$PERCENTAGE" = "" ]; then
    exit 0
fi

case "${PERCENTAGE}" in
    9[0-9]|100)
        color="0xffffffff" # pure white (reference max)
        ;;
    [7-8][0-9])
        color="0xffffff00" # full yellow (max luminous)
        ;;
    [5-6][0-9])
        color="0xffffaa00" # nuclear amber
        ;;
    [3-4][0-9])
        color="0xffff2a00" # hyper orange-red
        ;;
    [1-2][0-9])
        color="0xffff0066" # neon pink-red (VERY bright)
        ;;
    *)
        color="0xffff0044" # screaming red
        ;;
esac

if [ "$CHARGING" != "" ]; then
    icon="󰠠"
    icon_color="0xff00ff00"
else
    icon_color="$color"
    case "${PERCENTAGE}" in
        [0][0-9])
            icon="󰂎"
            ;;
        [1][0-9])
            icon="󰁺"
            ;;
        [2][0-9])
            icon="󰁻"
            ;;
        [3][0-9])
            icon="󰁼"
            ;;
        [4][0-9])
            icon="󰁽"
            ;;
        [5][0-9])
            icon="󰁾"
            ;;
        [6][0-9])
            icon="󰁿"
            ;;
        [7][0-9])
            icon="󰂀"
            ;;
        [8][0-9])
            icon="󰂁"
            ;;
        [9][0-9])
            icon="󰂂"
            ;;
        *)
            icon="󰁹"
            ;;
    esac
fi


# The item invoking this script (name $NAME) will get its icon and label
# updated with the current battery status
sketchybar --set "$NAME" label="${PERCENTAGE}" \
    icon.drawing="on" \
    icon="$icon" \
    icon.color="$icon_color" \
    label.color="$color" \
    # background.drawing="$background_drawing" \
    # background.color="$background_color" \
    # background.align="center" \
    # background.height="20" \
    # background.corner_radius="5"
