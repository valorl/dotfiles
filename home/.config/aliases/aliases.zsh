(($+commands[nvim])) && alias vim="nvim" vimdiff="nvim -d"

# Verbosity
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -v"
alias mkd="mkdir -pv"

alias vimy="vim -c 'set ft=yaml'"
alias vimj="vim -c 'set ft=json' -c '%!jq'"
alias vimx="vim -c 'set ft=xml'"
alias oil="nvim -c 'Oil'"

# Colors
alias ls="ls -ahN --color=auto --group-directories-first"
alias grep="grep --color=auto"
alias diff="diff --color=auto"

alias l1="ls -1"
alias ll="ls -alh"


function cdg() {
    cd "$(git rev-parse --show-toplevel)"
}

function cdf() {
    cd $(fd -t d | fzf --layout=reverse)
}

# awp is an AWS_PROFILE picker
function awp() {
    local profile=$({
        cat ~/.aws/config | sed -n 's/^\[profile \(.*\)\]$/\1/p'
        cat ~/.aws/credentials | sed -n 's/^\[\(.*\)\]$/\1/p'
    } | grep -v -E 'default' | fzf +m) 

    export AWS_PROFILE=$profile
} 

# derive_aws_profile sets and exports the AWS_PROFILE variable
# based on current directory
function derive_dir_aws_profile() {
    case $(pwd) in
        *"dev")
            export AWS_PROFILE=dev-admin
            ;;
        *"stag")
            export AWS_PROFILE=stag-admin
            ;;
        *"prod")
            export AWS_PROFILE=prod-admin
            ;;
        *"shrd")
            export AWS_PROFILE=shrd-admin
            ;;
    esac
}
# execute derive_dir_aws_profile on cd
chpwd_functions+=(derive_dir_aws_profile)


function dotsource() {
    prefix="$HOME/repos/github.com/valorl/dotfiles/home/"
    file=$(find $prefix \
        -type f \( -name "*.zsh" -o -name "*.sh" -o -name ".zshrc" -o -name ".zshenv" \) \
        | xargs -I{} bash -c "in={}; echo "\${in}" \${in#$prefix}" \
        | fzf --with-nth=2 | cut -d' ' -f2)

    source "$HOME/$file"
    echo "✅ sourced $file"
}

alias dots=dotsource

function pg() {
    local db=$(cat ~/.pgclirc.ini | yq -p toml '.alias_dsn | keys[]' | fzf)
    PGPASSWORD=$(gcloud sql generate-login-token) /opt/homebrew/bin/pgcli -D "$db" $@
}

