export EDITOR=nvim
export DAGGERVERSE=~/repos/github.com/quantumgas/daggerverse
export UV_KEYRING_PROVIDER=subprocess
export PGCLIRC=~/.pgclirc.ini

export XDG_CONFIG_HOME=~/.config

typeset -U PATH path

# set_path prepends entries to PATH
# wrapped in a function as it needs to be called here
# as well as later in .zshrc due to /usr/libexec/path_helper
# that runs after .zshenv and re-orders PATH
# https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2
function set_path() {
    eval "$(/opt/homebrew/bin/brew shellenv)"
    path=(
        # python
        "/opt/homebrew/opt/python@3.13/libexec/bin"
        # Use GNU utils on mac
        "/opt/homebrew/opt/coreutils/libexec/gnubin"
        "/opt/homebrew/opt/findutils/libexec/gnubin"
        "/opt/homebrew/opt/gnu-indent/libexec/gnubin"
        "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
        "/opt/homebrew/opt/gnutls/libexec/gnubin"
        "/opt/homebrew/opt/grep/libexec/gnubin"
        "/opt/homebrew/opt/gnu-tar/libexec/gnubin"
        "/opt/homebrew/opt/gawk/libexec/gnubin"

        # psql via libpq (to avoid installing full postgres)
        "/opt/homebrew/opt/libpq/bin"

        "$HOME/.local/bin"
        # dunno when this changed but I have no $GOPATH by default anymore
        # "$GOPATH/bin"
        "$HOME/go/bin"
        "$HOME/.krew/bin"
        "$HOME/.dotnet/tools"
        "$HOME/.cargo/bin"
        "./node_modules/.bin"

        $path
    )
    export PATH
}
set_path

source ~/.secretenv
. "$HOME/.cargo/env"
