function _k9s() {
    NO_PROFILE=false
    while [[ $# -gt 0 ]]; do
        case $1 in
            --context)
                CONTEXT="$2"
                shift; shift
                ;;
            --profile)
                PROFILE="$2"
                shift; shift
                ;;
            --no-profile)
                NO_PROFILE=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done


    local k9s_bin=""

    for p in "$HOME/.local/bin/k9s" "/usr/local/bin/k9s" "/usr/bin/k9s" "/bin/k9s"; do
        [ -f "$p" ] && { k9s_bin="$p"; break }
    done

    if [ $# -gt 0 ]
    then
        $k9s_bin $@
    else
        cmd=( $k9s_bin --context $CONTEXT --command node)

        if [ "$NO_PROFILE" = "false" ]
        then
            cmd=("AWS_PROFILE=$PROFILE" "$cmd[@]")
        fi

        echo "noProfile: $noProfile"
        echo "Launching k9s (profile: $profile, context: $context)"
        echo "cmd: $cmd[@]"
        eval "$cmd[@]"
    fi
}

function _k9s_profile() {
    local suffix="$1"; shift
    if [ -z "$suffix" ]; then
        >&2 echo "error: no suffix"
        return
    fi

    local context=$(kubectl config get-contexts --no-headers -o name | fzf -1 +m)

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
    _k9s --profile $profile --context $context $@
}

function k9sr() {
    _k9s_areyousure && _k9s_profile "read" $@
}
function k9sa() {
    _k9s_areyousure && _k9s_profile "admin" $@
}

function _k9s_areyousure() {
    # this is how zsh does read with prompt :shrug:
    read "answer?Are you sure you don't want to get better at kubectl instead!? "
    case $answer in
        "I am sure" ) return 0;;
        * ) return 1;;
    esac
}
