alias tf=_terraform
alias tfi="tf init"
alias tfp="_terraform plan"
alias tfp="_terraform plan"
alias tfpa="_terraform_plan && _terraform_apply"
alias tfip="tf init && _terraform plan"
alias tfia="tf init && _terraform_apply"

PLANFILE="plan.tfplan"

# _terraform is a wrapper around the terraform binary that:
#   runs tfswitch prior, ensuring correct TF version
#   generates a plan file
function _terraform() {
  binPath="$HOME/.local/bin/terraform"
  if command -v tfswitch &> /dev/null; then
    tfswitch -b "$binPath" 1>&2 > /dev/null
  fi

  if [ "$1" = "plan" ]; then
      shift
      terraform plan -out $PLANFILE $@
  elif [ "$1" = "show" ]; then
      >&2 echo "----------------------------------------------------------"
      >&2 echo " PLAN FROM: $(stat --format '%w' $PLANFILE)"
      >&2 echo "----------------------------------------------------------"
      terraform $@
  else
      terraform $@
  fi
}

function _terraform_apply() {
    if [ -e "$PLANFILE" ]; then
        terraform apply $@ $PLANFILE
    else
        terraform apply $@
    fi
}
