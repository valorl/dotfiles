#!/bin/sh
nocolor=$1

fmt_color() {
  if [ "$nocolor" = "--no-color" ]
  then
    printf "${1}"
  else
    color='\033[0;32m'
    nc='\033[0m'
    printf "${color}${1}${nc}"
  fi
}

log() {
  prefix="[$1]"
  text=$2
  echo "$(fmt_color $prefix) $2"
}

smart_link() {
  src=$1
  dst=$2
  if [ -d $dst ]
  then
    rm -r $dst
  else
    mkdir -p $(dirname $dst)
  fi
  ln -sf $src $dst
}


config_init() {
  [ ! -d $HOME/.config ] && mkdir $HOME/.config
}

config_add() {
  src=$(pwd)/config/$1
  dst=$HOME/.config/$1
  smart_link $src $dst
  log "~/.config" "$src -> $dst"
}

root_add() {
  src=$(pwd)/$1
  dst=$HOME/$1
  ln -sf $src $dst && log "~" "$src -> $dst"
}

scripts_init() {
  # Link whole dir
  # (all scripts should be source controlled)
  src=$(pwd)/scripts
  dst=$HOME/.scripts
  smart_link $src $dst && log "~/.scripts" "$src -> $dst"
}

bin_init() {
  src=$(pwd)/bin/*
  dst=$HOME/.local/bin
  [ ! -d $dst ] && mkdir -p $dst
  ln -sf $src $dst && log "~/.local/bin" "$src -> $dst"
}

# Home root
root_add .profile
root_add .zshenv
root_add .gitconfig

# ~/.config
config_init

config_add aliases
config_add bspwm
config_add fontconfig
config_add nvim
config_add nvim/coc-settings.json
config_add polybar
config_add sxhkd
config_add zsh/zsh_plugins.txt
config_add zsh/.zshrc
config_add Xresources
config_add starship.toml

# ~/.scripts
scripts_init

# ~/.local/bin
bin_init









