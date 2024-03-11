# plugins
source $HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh
antidote load

# set PATH again
# see .zshenv
set_path

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

# zsh-history-substring-search bindings
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Ctrl+x e to edit command line content
autoload edit-command-line
zle -N edit-command-line
bindkey '^xe' edit-command-line

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

function t() {
    if (($+commands[tmux])) && [ -z "$TMUX" ]
    then
        tmux -f ~/.config/tmux/tmux.conf attach -t base || tmux -f ~/.config/tmux/tmux.conf new -s base
    fi
}

for f in ~/.config/aliases/*.zsh; do
    source $f
done


# kc (see aliases)
function kc_export() {
    [ -e "/tmp/kc_$$" ] && export KUBECONFIG=/tmp/kc_$$
}
typeset -a precmd_functions
precmd_functions+=(kc_export)

# kc cleanup
kc_trap_exit() {
  [ -e "/tmp/kc_$$" ] && rm /tmp/kc_$$ > /dev/null
}
trap kc_trap_exit EXIT


# FZF integration
source "/opt/homebrew/opt/fzf/shell/completion.zsh"
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# ~/.zshrc
# export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense' # optional
# zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# prompt
(($+commands[starship])) && eval "$(starship init zsh)"

