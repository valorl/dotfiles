# FZF ZSH integration
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

source ~/.config/zsh/.zsh_plugins.sh

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

# Aliases
source ~/.config/aliases/aliasrc




# Fix ls colors
LS_COLORS="ow=01;36;40" && export LS_COLORS
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zmodload zsh/complist
autoload -U compinit && compinit

# Initialize starship
eval "$(starship init zsh)"
