REPOS="$HOME/repos"

alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcne!='git commit -v --no-edit --amend'
alias gca='git commit -v -a'
alias gca!='git commit -v -a --amend'
alias gcane!='git commit -v -a --no-edit --amend'
alias gcm='git commit -m'
alias gcam='git commit -a -m'

alias gco='git checkout'
alias gcob='git checkout -b'
alias gcom='git checkout master'

alias gd='git diff'
alias gds='git diff --staged'

alias gs='git stash'
alias gsp='git stash pop'

alias gst='git status -s'

alias gpsu='git push --set-upstream origin $(git branch --show-current)'

alias grim='git rebase -i master'
alias gri2='git rebase -i HEAD~2'
alias gri3='git rebase -i HEAD~3'
alias gri4='git rebase -i HEAD~4'
alias gri5='git rebase -i HEAD~5'
alias gri6='git rebase -i HEAD~6'
alias gri7='git rebase -i HEAD~7'
alias gri8='git rebase -i HEAD~8'
alias gri9='git rebase -i HEAD~9'
alias gri10='git rebase -i HEAD~10'

# _cd_rename_window changes directory and renames tmux window
# assumes a repository absolute path
function _cd_rename_window() {
    cd $1
    if [ -n "$TMUX" ]; then
        current_window="$(tmux display-message -p '#I')"
        name="$(echo "$1" | rev | cut -d / -f1,2 | rev)"
        tmux rename-window -t "$current_window" "$name"
    fi
}

# _gclone_parse_remote parses the remote git URL
# and returns a path incl. host, excl. protocol and .git
# TODO: unit test?
function _gclone_parse_remote() {
    local url="$1"
    # Trim protocol
    name=${url#"https://"}
    name=${name#"git@"}
    # Trim .git suffix
    name=${name%.git}
    # Replace : after hostname (if git@ style URL)
    echo "${name/://}"
}

# gclone clones the repository into $REPOS,
# replicating the git host and path in the filesystem
function gclone() {
    local remote_url="$1"
    local name="$(_gclone_parse_remote $remote_url)"

    local dest="$REPOS/$name"
    mkdir -p $dest
    git clone $remote_url $dest

    _cd_rename_window $dest
}

function gclone_gh() {
    if [ -z "$1" ]; then
        echo "error: missing query"
        return 1
    fi

    local repo="$(gh search repos $@ --json fullName,description \
        | jq -r '.[] | "\(.fullName) \(.description)"' \
        | fzf --ansi --with-nth 1 --preview 'echo {} | cut -d" " -f2-' \
        --preview-window=up:10% --layout reverse --height 15 \
        | cut -d' ' -f1)"

    if [ -z "$repo" ]; then
        return 1
    fi

    local url="git@github.com:${repo}.git"
    gclone $url
}


function _git_log_default() {
    esc=$(printf '\033')
    light_purple='[1;35m'
    git log \
        --pretty='%C(bold yellow)%h%Creset %<(11)%Cgreen%ad %<(15,trunc)%Cblue%al%Creset %s %C(auto)%d%Creset' \
        --date=short \
        --color=always \
        $@ \
        | nl -v0 -w2 -nrn -s' ' \
        | less -R
}
alias glog="_git_log_default"

function gri {
    n=$(_git_log_default \
        | fzf --ansi --layout reverse --preview 'git show --name-status {+2} | diff-so-fancy' --preview-window top \
        | cut -d' ' -f2)
    git rebase -i "HEAD~$n"
}


# Fugitive
function :G() {
    nvim -c ":Ge :"
    git status -s
}

function rp() {
    (($+commands[fd])) || {
        echo "'fd' not installed"
        return
    }
    
    # TODO?
    # local icon_gl=" "
    # local icon_gh=" "

    local xargs_cmd="$(printf 'in="{}"; pretty="${in#%s/}"; echo "$in $pretty"' $REPOS)"

    # find all git repos in $REPOS
    # append pretty representation for fuzzy finding
    # fuzzy find
    # output selected as original full path
    local selected=$(fd '\.git$' --full-path $REPOS --prune -u -t d -x echo {//} \
        | xargs -P4 -I {} bash -c "$xargs_cmd" \
        | fzf --with-nth 2 --layout=reverse --height 10 --select-1 --query "$1" \
        | cut -d' ' -f1)

    echo $selected | {
        read first _
        [[ "$first" == "" ]] && return 1
        _cd_rename_window "$first"
    }
}
