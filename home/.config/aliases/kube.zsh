alias k="kubectl"
alias kaf="kubectl apply -f"
alias kafs="kubectl apply --server-side -f"

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

    // if first argument is not --no-profile
    if [ "$1" != "--no-profile" ]; then
        case $choice in
            *"dev"*)
                export AWS_PROFILE=dev-admin
                ;;
            *"stag"*)
                export AWS_PROFILE=stag-admin
                ;;
            *"prod"*)
                export AWS_PROFILE=prod-admin
                ;;
            *"shrd"*)
                export AWS_PROFILE=shrd-admin
                ;;
        esac
    fi
}
