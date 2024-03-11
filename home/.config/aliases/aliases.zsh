(($+commands[nvim])) && alias vim="nvim" vimdiff="nvim -d"

# Verbosity
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias mkd="mkdir -pv"

alias vimy="vim -c 'set ft=yaml'"

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

# kc is a per shell-scoped kubernetes context switcher
#
# It fuzzy selects a context from the default kubeconfig ($HOME/.kube/config)
# and creates a new config with current-context set to the selected context.
# The new config is saved in a temporary file bound by naming convention to the
# particular shell PID (/tmp/kc_$$)
#
# The shell-specific config should be automatically detected and exported
# under KUBECONFIG as part of the shell's precmd hook.
# 
# In ~/.zshrc:
#   function kc_export() {
#       [ -e "/tmp/kc_$$" ] && export KUBECONFIG=/tmp/kc_$$
#   }
#   typeset -a precmd_functions
#   precmd_functions+=(kc_export)
#
#   # kc cleanup
#   kc_trap_exit() {
#     [ -e "/tmp/kc_$$" ] && rm /tmp/kc_$$ > /dev/null
#   }
#   trap kc_trap_exit EXIT
#
function kc() {
    fzf_args=("--layout=reverse" "--height=10")
    base="$HOME/.kube/config"
    choice=$(yq '.contexts[] | .name' $base | fzf "${fzf_args[@]}")
    yq ".current-context = \"$choice\"" $base > /tmp/kc_$$
}
