ctx=$(sed -n "s/current-context: \(.*\)/\1/p" ~/.kube/config)
case $ctx  in
    *"dev"*)
        export AWS_PROFILE=dev
        ;;
    *"stag"*)
        export AWS_PROFILE=stag
        ;;
    *"stag"*)
        export AWS_PROFILE=stag
        ;;
    *"prod"*)
        export AWS_PROFILE=prod
        ;;
esac
