alias tf=_tofu
alias tfi="tf init"
alias tfp="_tofu plan"
alias tfa="_tofu_apply"
alias tfpa="tfp && tfa"
alias tfip="tf init && _tofu plan"
alias tfia="tf init && _tofu_apply"

PLANFILE="plan.tfplan"

# _tofu is a wrapper around the tofu binary that always generates a plan file 
function _tofu() {
  if [ "$1" = "plan" ]; then
      shift
      tofu plan -out $PLANFILE $@
  elif [ "$1" = "show" ]; then
      >&2 echo "----------------------------------------------------------"
      >&2 echo " PLAN FROM: $(stat --format '%w' $PLANFILE)"
      >&2 echo "----------------------------------------------------------"
      tofu $@
  else
      tofu $@
  fi
}

function _tofu_apply() {
    if [ -e "$PLANFILE" ]; then
        tofu apply $@ $PLANFILE
    else
        tofu apply $@
    fi
}

function _tofu_project_picker() {
    # find all terraform roots (excl. modules/) in current git repo
    fd --type d \
        --exclude .terraform \
        --exclude modules \
        --exec sh -c 'test -f {}/main.tf && echo {}' \; \
        . "$(git rev-parse --show-toplevel)" \
        | sed "s|$(git rev-parse --show-toplevel)/||" \
        | fzf --layout=reverse \
            --preview 'bat --color=always "$(git rev-parse --show-toplevel)/"{1}"/main.tf"' \
            --preview-window=top:60% \
            --select-1 \
            --query "$1"
}


function tp() {
    cd $(git rev-parse --show-toplevel)/$(_tofu_project_picker "$1")
}


