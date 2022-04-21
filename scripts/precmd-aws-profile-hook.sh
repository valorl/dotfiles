[[ "${PWD}" == *"terraform/envs"* ]] && return 0;
[[ "$VALORL_AWS_PROFILE_HOOK_SUSPEND" == "1" ]] && return 0
if [ -n "$KUBECONFIG" ]; then
    config="$KUBECONFIG"
else
    config="$HOME/.kube/config"
fi

[ -f "$config" ] && {
    ctx=$(sed -n "s/current-context: \(.*\)/\1/p" "$config")
    case $ctx  in
        *"dev"*)
            export AWS_PROFILE=dev
            ;;
        *"stag"*)
            export AWS_PROFILE=stag
            ;;
        *"shrd"*)
            export AWS_PROFILE=shrd
            ;;
        *"prod"*)
            export AWS_PROFILE=prod
            ;;
    esac
}
