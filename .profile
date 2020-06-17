# Neat ~
export ZDOTDIR="$HOME/.config/zsh"
export LESSHISTFILE="-"
export HISTFILE="$HOME/.config/zsh/.zsh_history"
#export WGETRC="$HOME/.config/inputrc"
#export AWS_CONFIG_FILE="$HOME/.config/aws/config"
#export AWS_SHARED_CREDENTIALS_FILE="$HOME/.config/aws/credentials"

# Defaults
export EDITOR="nvim"
export TERMINAL="st"
export BROWSER='/mnt/c/Program Files (x86)/BraveSoftware/Brave-Browser/Application/brave.exe'


# Dev stuff
export REPOS=$HOME/repos
export GOPATH=$HOME/go
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export DOCKER_HOST=tcp://localhost:2375
export VISUAL_STUDIO="/mnt/c/Program\ Files\(x86\)/Microsoft\ Visual\ Studio/2019/Professional/Common7/IDE/devenv.exe"

# Sensitive stuf
[ -f ~/.secretprofile ] && source ~/.secretprofile

# PATH
typeset -U PATH path
path=(
  "$HOME/.local/bin"
  "$GOPATH/bin"
  "$HOME/.krew/bin"
  "$HOME/.dotnet/tools"

  $path
)
export PATH
