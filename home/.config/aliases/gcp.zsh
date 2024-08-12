function gp() {
    local cache_dir="$HOME/.cache/gcloud"
    local projects_file="$cache_dir/projects.json"

    # create cache parent if doesn't exist
    # should only happen on fresh setup
    if [ ! -d $cache_dir ]; then
        mkdir -p $cache_dir
        echo "gp: created $cache_dir"
    fi

    # either if the cache file doesn't exist or if manually forced
    if [ "$1" = "-f" ] || [ ! -f "$projects_file" ]; then
        gcloud projects list --format json > $projects_file
    fi

    local project=$(cat $projects_file | jq '.[] | .projectId' -r | fzf +m)
    export CLOUDSDK_CORE_PROJECT=$project
}

function _gcloud_pick_role() {
    local cache_dir="$HOME/.cache/gcloud"
    local roles_file="$cache_dir/roles.json"

    # create cache parent if doesn't exist
    # should only happen on fresh setup
    if [ ! -d $cache_dir ]; then
        mkdir -p $cache_dir
        echo "groles: created $cache_dir"
    fi

    # either if the cache file doesn't exist or if manually forced
    if [ "$1" = "-f" ] || [ ! -f "$roles_file" ]; then
        gcloud iam roles list --format json > $roles_file
    fi

    local role=$(cat $roles_file | jq '.[] | "\(.name) | \(.description)"' -r | fzf +m | cut -d' ' -f1)
    echo "$role"
}

function gimme() {
    local role="$(_gcloud_pick_role)"
    gcloud organizations add-iam-policy-binding 404107827481 \
        --member="user:vao@qgt.dk" \
        --role="$role"
}

function groledes() {
    local role="$(_gcloud_pick_role)"
    gcloud iam roles describe "$role"
}

function glogin() {
    gcloud auth login --update-adc
}
