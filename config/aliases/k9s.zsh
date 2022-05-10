function k9s() {

  noProfile=false
  if [ "$1" = "--no-profile" ]; then
    noProfile=true
    shift
  fi

  local k9s_bin=""

  for p in "$HOME/.local/bin/k9s" "/usr/local/bin/k9s" "/usr/bin/k9s" "/bin/k9s"; do
      [ -f "$p" ] && { k9s_bin="$p"; break }
  done

  if [ $# -gt 0 ]
  then
    $k9s_bin $@
  else
    context=$(kubectl config get-contexts --no-headers -o name | fzf -1 +m)
    cmd=( $k9s_bin --context $context --command node)
    profile=""

    if [ "$noProfile" = "false" ]
    then
      case $context in
        *"dev"*)
          profile=kube-dev
          ;;
        *"stag"*)
          profile=kube-stag
          ;;
        *"shrd"*)
          profile=kube-shrd
          ;;
        *"prod"*)
          profile=kube-prod
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
