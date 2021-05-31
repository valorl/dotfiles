# Neat ~
export ZDOTDIR="$HOME/.config/zsh"
export LESSHISTFILE="-"
export HISTFILE="$HOME/.config/zsh/.zsh_history"
#export WGETRC="$HOME/.config/inputrc"
#export AWS_CONFIG_FILE="$HOME/.config/aws/config"
#export AWS_SHARED_CREDENTIALS_FILE="$HOME/.config/aws/credentials"
export AWS_DEFAULT_REGION=eu-central-1

# Defaults
export EDITOR="nvim"
export TERM="screen-256color"
export TERMINAL="st"
export GPG_TTY=$(tty)
export BROWSER='eval "/mnt/c-drive/c/Program Files (x86)/BraveSoftware/Brave-Browser/Application/brave.exe"'

# Dev stuff
export REPOS=$HOME/repos
export GOPATH=$HOME/go
export DOTNET_CLI_TELEMETRY_OPTOUT=1
#export VISUAL_STUDIO="/mnt/c/Program\ Files\(x86\)/Microsoft\ Visual\ Studio/2019/Professional/Common7/IDE/devenv.exe"
export DOCKER_BUILDKIT=1

# Sensitive stuf
[ -f ~/.secretprofile ] && source ~/.secretprofile

cDriveBase="/mnt/c-drive/c"

# PATH
typeset -U PATH path
path=(
  "$HOME/.local/bin"
  "$GOPATH/bin"
  "$HOME/.krew/bin"
  "$HOME/.dotnet/tools"
  "$HOME/.cargo/bin"

  "$cDriveBase/Program Files/Microsoft Vs Code/bin"
  "$cDriveBase/Program Files (x86)/BraveSoftware/Brave-Browser/Application"
  $path
)
export PATH
