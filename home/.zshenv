typeset -U PATH path

# set_path prepends entries to PATH
# wrapped in a function as it needs to be called here
# as well as later in .zshrc due to /usr/libexec/path_helper
# that runs after .zshenv and re-orders PATH
# https://gist.github.com/Linerre/f11ad4a6a934dcf01ee8415c9457e7b2
function set_path() {
    eval "$(/opt/homebrew/bin/brew shellenv)"
    path=(
        # Use GNU utils on mac
        "/opt/homebrew/opt/coreutils/libexec/gnubin"
        "/opt/homebrew/opt/findutils/libexec/gnubin"
        "/opt/homebrew/opt/gnu-indent/libexec/gnubin"
        "/opt/homebrew/opt/gnu-sed/libexec/gnubin"
        "/opt/homebrew/opt/gnutls/libexec/gnubin"
        "/opt/homebrew/opt/grep/libexec/gnubin"
        "/opt/homebrew/opt/gnu-tar/libexec/gnubin"
        "/opt/homebrew/opt/gawk/libexec/gnubin"

        "$HOME/.local/bin"
        "$GOPATH/bin"
        "$HOME/.krew/bin"
        "$HOME/.dotnet/tools"
        "$HOME/.cargo/bin"
        "./node_modules/.bin"

        $path
    )
    export PATH
}
set_path

# secret env vars
eval "$(ring get globals.sh)"

