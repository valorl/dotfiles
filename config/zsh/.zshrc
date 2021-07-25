# FZF ZSH integration
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

source "$HOME/.config/zsh/zsh_plugins.sh"

# Setup history
export HISTSIZE=9999999999
export SAVEHIST=$HISTSIZE
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_verify
setopt hist_ignore_space
setopt appendhistory
setopt inc_append_history
setopt share_history

# Fix i/a commands in vi-mode
autoload -U select-bracketed
autoload -U select-quoted
zle -N select-quoted
zle -N select-bracketed
for km in visual viopp; do
    bindkey -M $km -- '-' vi-up-line-or-history
    for c in {a,i}${(s..)^:-\'\"\`\|,./:;-=+@}; do
        bindkey -M $km $c select-quoted
    done
    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M $km $c select-bracketed
    done
done

# Make vi-mode more responsive
export KEYTIMEOUT=1

# zsh-history-substring-search bindings
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Ctrl+x e to edit command line content
autoload edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line

# Aliases
source ~/.config/aliases/aliasrc

# Fix ls colors
LS_COLORS="ow=01;36;40" && export LS_COLORS
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zmodload zsh/complist
autoload -U compinit && compinit

function set_win_title(){
  echo -ne "\033]0; $(pwd) \007"
}
precmd_functions+=(set_win_title)
# cd hook
function chpwd() {
    emulate -L zsh
    source $HOME/.scripts/chpwd-aws-profile-hook.sh
}

#precmd hook
function precmd() {
    emulate -L zsh
    source $HOME/.scripts/precmd-aws-profile-hook.sh
}

# Start tmux session
if [ -z "$TMUX" ]
then
    tmux -f ~/.config/tmux/tmux.conf attach -t base || tmux -f ~/.config/tmux/tmux.conf new -s base
fi

# Initialize starship
eval "$(starship init zsh)"
