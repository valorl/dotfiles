(($+commands[nvim])) && alias vim="nvim" vimdiff="nvim -d"

# Verbosity
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias mkd="mkdir -pv"

# Colors
# alias ls="ls -hN --color=auto --group-directories-first"
alias grep="grep --color=auto"
alias diff="diff --color=auto"

# awp is an AWS_PROFILE picker
function awp() {
    local profile=$({
        cat ~/.aws/config | sed -n 's/^\[profile \(.*\)\]$/\1/p'
        cat ~/.aws/credentials | sed -n 's/^\[\(.*\)\]$/\1/p'
    } | grep -v -E 'default' | fzf +m) 

    export AWS_PROFILE=$profile
} 
