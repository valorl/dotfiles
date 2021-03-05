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

path=$(echo -n $1 \
    | sed -r "s (git@|https://)(.*)\.git \2 " \
    | sed "s : / ")
echo "Creating $path.."
mkdir -p $path
git clone $1 $path

