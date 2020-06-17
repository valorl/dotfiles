#!/bin/sh
profile=$(cat ~/.aws/credentials | sed -n 's/^\[\(.*\)\]$/\1/p' | fzf +m)
export AWS_PROFILE=$profile

