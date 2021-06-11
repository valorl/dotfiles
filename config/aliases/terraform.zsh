alias tf=_terraform
alias tfi="tf init"
alias tfp=_terraform_plan

alias tfip="tf init && tf plan"

function _terraform() {
  binPath="$HOME/.local/bin/terraform"

  if command -v tfswitch &> /dev/null
  then
    tfswitch -b "$binPath" > /dev/null
    eval "$binPath $@"
  else
    terraform $@
  fi
}

function _terraform_plan() {
  _terraform plan -out=plan.tfplan $@
}

