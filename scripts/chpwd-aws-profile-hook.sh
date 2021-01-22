case $(pwd) in
    *"terraform/envs/dev"*)
        export AWS_PROFILE=dev
        ;;
    *"terraform/envs/stag"*)
        export AWS_PROFILE=stag
        ;;
    *"terraform/envs/prod"*)
        export AWS_PROFILE=prod
        ;;
    *"terraform/envs/shrd"*)
        export AWS_PROFILE=shrd
        ;;
esac
