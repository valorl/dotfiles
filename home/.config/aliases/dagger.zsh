function qrshi() {
    repo="$HOME/repos/github.com/quantumgas/daggerverse"
    _git_is_uptodate "$repo" "WARN: Local daggerverse not up-to-date!"

    qmodule="$1"

    dagger -m "$repo/$qmodule" shell
}

function qrsh() {
    repo="$HOME/repos/github.com/quantumgas/daggerverse"
    _git_is_uptodate "$repo" "WARN: Local daggerverse not up-to-date!"

    qmodule="$1"

    dagger -m "$repo/$qmodule" -c "$@"
}

function qr!() {
    prefix="git@github.com:quantumgas/daggerverse"
    # repo="$HOME/repos/github.com/quantumgas/daggerverse"
    dagger call -m $prefix/$@
}

function qr() {
    # prefix="git@github.com:quantumgas/daggerverse"
    repo="$HOME/repos/github.com/quantumgas/daggerverse"
    _git_is_uptodate "$repo" "WARN: Local daggerverse not up-to-date!"
    dagger call -m $repo/$@
}

function _git_is_uptodate() {
    repo="$1"
    msg="$2"
    git -C "$repo" fetch
    [ "$(git -C "$repo" rev-parse HEAD)" = "$(git -C "$repo" rev-parse @{upstream})" ] || echo "$msg"
}
