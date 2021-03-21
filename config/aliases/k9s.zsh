function k9s() {

  noProfile=false
  if [ "$1" = "--no-profile" ]
  then
    noProfile=true
    shift
  fi


  if [ $# -gt 0 ]
  then
    /usr/local/bin/k9s $@
  else
    context=$(kubectl config get-contexts --no-headers -o name | fzf +m)
    cmd=( /usr/local/bin/k9s --context $context --command node)
    profile=""

    if [ "$noProfile" = "false" ]
    then
      case $context in
        *"dev"*)
          profile=dev
          ;;
        *"stag"*)
          profile=stag
          ;;
        *"shrd"*)
          profile=shrd
          ;;
        *"prod"*)
          profile=prod
          ;;
      esac
      cmd=("AWS_PROFILE=$profile" "$cmd[@]")
    fi

    echo "noProfile: $noProfile"
    echo "Launching k9s (profile: $profile, context: $context)"
    echo "cmd: $cmd[@]"
    eval "$cmd[@]"
  fi
}
