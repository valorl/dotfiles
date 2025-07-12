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
