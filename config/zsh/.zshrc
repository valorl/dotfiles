# FZF ZSH integration
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

source <(antibody init)
antibody bundle < ~/.config/zsh/plugins.txt


# Make vi-mode more responsive
KEYTIMEOUT=1

# zsh-history-substring-search bindings
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Aliases
source ~/.config/aliases/aliasrc



# Fix ls colors
LS_COLORS="ow=01;36;40" && export LS_COLORS
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"

# Initialize starship
eval "$(starship init zsh)"
