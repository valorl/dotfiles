alias dn="dotnet"
alias dnar="dotnet add reference"

function dnap() {
    if ls *.csproj > /dev/null 2>&1
    then
        dotnet add package $@
    else
        proj=$(find . -name '*.csproj' | fzf)
        dotnet add $proj package $@
    fi
}


# _dotnet_solution_aware_cd() {
#   if [[ -n "$1" && -n "$SOLUTION_NAME" ]]; then
#     local target="${SOLUTION_NAME}.$1"
#     if [[ -d "$target" ]]; then
#       builtin cd "$target"
#       return
#     fi
#   fi
#   builtin cd "$@"
# }
#
#
# _activate_dotnet_solution_aware_cd() {
#   local sln
#   sln=(*.sln(N[1]))
#
#   if [[ -n "$sln" ]]; then
#     export SOLUTION_NAME="${sln%.sln}"
#
#     # only override if not already overridden
#     if [[ "$(whence -w cd)" != *_dotnet_solution_aware_cd* ]]; then
#       alias cd='_dotnet_solution_aware_cd'
#     fi
#   else
#     unset SOLUTION_NAME
#     unalias cd 2>/dev/null
#   fi
# }
#
# chpwd_functions+=(_activate_dotnet_solution_aware_cd)
#
# # also run once for current dir when shell starts
# _activate_dotnet_solution_aware_cd
