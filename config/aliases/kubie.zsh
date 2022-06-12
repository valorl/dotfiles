function kx() {
    # local suffix="$1"; shift
    # if [ -z "$suffix" ]; then
    #     >&2 echo "error: no suffix"
    #     return
    # fi

    local context=$(kubectl config get-contexts --kubeconfig $HOME/.kube/config --no-headers -o name | fzf -1 +m)
    local admin=$(echo $'no\nyes' | fzf --prompt "Admin (MFA) ? ")

    local suffix=""
    case $admin in
        "yes")
            suffix="admin";;
        *)
            suffix="read";;
    esac

    local profile=""
    case $context in
        *"dev"*)
            profile="dev-$suffix"
            ;;
        *"stag"*)
            profile="stag-$suffix"
            ;;
        *"shrd"*)
            profile="shrd-$suffix"
            ;;
        *"prod"*)
            profile="prod-$suffix"
            ;;
    esac

    >&2 echo "profile $profile"
    cmd=(AWS_PROFILE=$profile kubie ctx $context)
    # >&2 echo "Eval..."
    eval "$cmd[@]"
}
