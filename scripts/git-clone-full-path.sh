# https://gitlab.neasenergy.com/infrastructure/terraform/envs/test.git
if [ -z "$1" ]
then
    echo "No repository URL provided."
    exit 1
fi

if ! $(echo $1 | grep -Eq '^https://(.*)\.git$')
then
    echo "Not a valid repository URL."
    exit 1
fi

path=$(echo -n $1 | sed "s https://\(.*\)\.git \1 ")
echo "Creating $path.."
mkdir -p $path
git clone $1 $REPOS/local/$path

