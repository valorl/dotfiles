# lib
function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

# Pretty log messages
function _git_log_prettily(){
  if ! [ -z $1 ]; then
    git log --pretty=$1
  fi
}
#compdef _git _git_log_prettily=git-log

function gclone() {
    local dir="$(sh "$HOME/.scripts/git-clone-full-path.sh" $1)"
    cd $dir
}

# Fugitive
function :G() {
    nvim -c ":Ge :"
    git status -s
}
alias g='git'

alias gaa='git add --all'

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

alias gpsu='git push --set-upstream origin $(git_current_branch)'

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

function groot() {
    cd $(git rev-parse --show-toplevel)
}

function _git_log_default() {
    esc=$(printf '\033')
    light_purple='[1;35m'
    git log \
        --pretty='%C(bold yellow)%h%Creset %<(11)%Cgreen%ad %<(15,trunc)%Cblue%al%Creset %s %C(auto)%d%Creset' \
        --date=short \
        --color=always \
        $@ \
        | nl -v0 | sed "s,^ \+,${esc}${light_purple}," | bat --plain
}
alias glogx="git log --pretty='%C(bold yellow)%h%Creset %<(11)%Cgreen%ad %<(15,trunc)%Cblue%al%Creset %s %C(auto)%d%Creset' --date=short"
alias glog="_git_log_default"

alias gst='git status -s'

function grename() {
  if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 old_branch new_branch"
    return 1
  fi

  # Rename branch locally
  git branch -m "$1" "$2"
  # Rename branch in origin remote
  if git push origin :"$1"; then
    git push --set-upstream origin "$2"
  fi
}

# xgit <dest> <command>
# runs <command> in each git repo directly in <dest>
function xgit() {
    local dests="$1" && shift
    if "$dests"
    find . -name .git -type d -execdir $@ \; -prune
}
