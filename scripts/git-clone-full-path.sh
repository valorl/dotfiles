# https://gitlab.neasenergy.com/infrastructure/terraform/envs/test.git
if [ -z "$1" ]
then
    echo "No repository URL provided."
    exit 1
fi

regexHTTPS='^https://(.*)\.git$'
regexSSH='^git@(.*)\.git$'
if ! $(echo $1 | grep -Eq "($regexHTTPS|$regexSSH)")
then
    echo "Not a valid repository URL."
    exit 1
fi

repo_path=$(echo -n $1 \
    | sed -r "s (git@|https://)(.*)\.git \2 " \
    | sed "s : / ")
full_path="$HOME/repos/local/$repo_path"
echo "Creating $full_path.."
mkdir -p $full_path
git clone $1 $full_path
cd $full_path
