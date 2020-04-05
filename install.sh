#!/bin/sh

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
  echo "[~/.config] $src -> $dst"
  smart_link $src $dst
}

root_add() {
  src=$(pwd)/$1
  dst=$HOME/$1
  echo "[~] $src -> $dst"
  ln -sf $src $dst
}

scripts_init() {
  # Link whole dir
  # (all scripts should be source controlled)
  src=$(pwd)/scripts
  dst=$HOME/.scripts
  smart_link $src $dst
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
config_add nvim/init.vim
config_add nvim/coc-settings.json
config_add polybar
config_add sxhkd
config_add zsh
config_add Xresources
config_add starship.toml

# ~/.scripts
scripts_init










