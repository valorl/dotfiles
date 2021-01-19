migrate() {
    echo "=== $(pwd) ==="
    old=$(git remote -v | head -n1 | awk '{ print $2}')
    echo $old
    new=$(echo -n $old | sed 's,https://gitlab.neasenergy.com/,git@gitlab.neasenergy.com:,g')
    echo $new
    git remote set-url origin $new
}

find_repo() {
    for d in "$@"; do
        test -d "$d" -a \! -L "$d" || continue
        cd "$d"
        if [ -d ".git" ]; then
            migrate
        else
            find_repo *
        fi
        cd ..
    done
}

find_repo $1/*
