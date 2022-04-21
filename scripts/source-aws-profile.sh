#!/bin/sh
#profile=$(cat ~/.aws/credentials | sed -n 's/^\[\(.*\)\]$/\1/p' | fzf +m)
function profiles() {
    cat ~/.aws/config | sed -n 's/^\[profile \(.*\)\]$/\1/p'
    cat ~/.aws/credentials | sed -n 's/^\[\(.*\)\]$/\1/p'
}
profile=$( profiles | grep -v -E 'default|_login' | fzf +m)

export AWS_PROFILE=$profile
