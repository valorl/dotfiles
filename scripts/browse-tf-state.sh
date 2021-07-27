#!/bin/bash

terraform_state_browse_preview() {
  local SELECTION=$@
  local MODULE=$( echo $SELECTION | cut -d' ' -f1 )
  local NAME=$( echo $SELECTION | cut -d' ' -f2 )
  local MODE=$( echo $SELECTION | cut -d' ' -f3 )
  local TYPE=$( echo $SELECTION | cut -d' ' -f4 )

  if [ -z "$TYPE" ]; then
    TYPE="$MODE"
    MODE="$NAME"
    NAME="$MODULE"
    MODULE=""
  fi

  local IDENTIFIER="$MODULE"
  if [ "$MODE" == "data" ]; then
    IDENTIFIER=$( echo "$IDENTIFIER.\e[35mdata\e[0m" | sed 's/^\.//g' )
  fi

  if [ "$MODE" == "resource" ]; then
    MODE="managed"
  fi

  IDENTIFIER=$( echo "$IDENTIFIER.\e[33m$TYPE\e[0m.\e[94m$NAME\e[0m" | sed 's/^\.//g' )

  IDENTIFIER=$( echo "$IDENTIFIER" | sed 's/module\./\\e\[38;5;237mmodule\\e\[0m./g' )

  echo -e "$IDENTIFIER"
  echo ""

  local QUERY='.resources[] | select((.module == null) and .mode == "<MODE>" and .type == "<TYPE>" and .name == "<NAME>")'

  if [ ! -z "$MODULE" ]; then
    QUERY='.resources[] | select(.module == "<MODULE>" and .mode == "<MODE>" and .type == "<TYPE>" and .name == "<NAME>")'
  fi

  QUERY=$(echo "$QUERY" |
    sed "s&<MODULE>&$MODULE&g" |
    sed "s&<MODE>&$MODE&g" |
    sed "s&<TYPE>&$TYPE&g" |
    sed "s&<NAME>&$NAME&g"
    )
  # echo $QUERY

  cat state.tfstate |
    jq -r -C "$QUERY"
}

export -f terraform_state_browse_preview

TF_RESOURCE_SELECTION=$(cat state.tfstate |
  jq -r '
    .resources[] |
    [.module, .name, if .mode == "managed" then "resource" else .mode end, .type] | join(" ") |ltrimstr(" ")' |
  fzf --no-mouse --preview 'terraform_state_browse_preview {}')
terraform_state_browse_preview "$TF_RESOURCE_SELECTION"
