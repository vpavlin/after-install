alias gco="git checkout"
alias gbra="git branch -a"
alias gp="git pull"
alias ga="git add"
alias gl="git log"
alias gst="git status"
alias gu="cat .git/config | grep url"

function gR() { [ -n "$*" ] && grep -Rn "$*"; }
#alias gR="grep -Rn \"$1\""

alias gitg="d gitg"
alias geany="d geany"

alias repoq7="repoquery --disablerepo=* --enablerepo=rhel7-latest"
alias repoq7opt="repoquery --disablerepo=* --enablerepo=rhel7-latest-opt"

alias repoq6="repoquery --disablerepo=* --enablerepo=rhel65"
alias repoq6opt="repoquery --disablerepo=* --enablerepo=rhel65-opt"

alias abspath="readlink -f"

alias dload="docker load -i"

alias ff="find . -type f -iname"

function gviml() { a=$1; f=${a%:*}; n=${a##*:}; [ -z $n ] && n=${f##*:} && f=${f%:*}; gvim +$n $f; }

function pkg() { if pwd | grep fedora ; then fedpkg $1; else if pwd | grep rhel ; then rhpkg $1 ; fi; fi;}

function mswap() { order="3 2 1"; if [ `xmodmap -pp | head -5 | tail -1 | awk '{print $2}'` == "3" ]; then order="1 2 3"; fi; xmodmap -e "pointer = $order" &> /dev/null;  }

function ginit() { git init; git add *; git commit -m "Init"; }

function cmd() { terminator -e "$1;read"; }

function cdgo() { cd "$GOPATH/src/github.com/$1"; }

function repoq() {
    repos=""
    while [ "$1" != "" ]; do
        grep -q "$1" /etc/yum.repos.d/* 2> /dev/null && repos=$repos" --enablerepo="$1 || break;
        shift
        done
    repoquery --disablerepo=* $repos $*
         }

function dr() {
    cmd="bash"

    [ $# -eq 2 ] && cmd=$2
    echo "podman run -it --rm $1 $cmd"
    podman run -it --rm $1 $cmd
}

#Remove all untagged images (<none>)
function docker-rmi-none() {
    docker rmi $(docker images | grep none | awk '{print $3}');
}

#Remove all containers
function docker-rm-all() {
    docker rm $(docker ps -aq)
}

#Stop all containers
function docker-stop-all() {
    docker stop $(docker ps -q)
}

#Run a container
#If CMD is not provided, uses bash, adds name in format tmp$NUMBER_OF_RUNNING_TMP_CONTS
function dr() {
    cmd="bash"
    image=$1
    [ $# -ge 2 ] && shift && cmd=$@
    run="podman run --name tmp$(podman ps -a | grep tmp | wc -l)  -it --rm $image $cmd"
    echo $run
    $run
}

#Call docker load. If the image is not specified by path, use default directory
function dl() {
    local path=$1
    local DEFAULT_PATH="${HOME}/devel/brew/"
    [[ "${path}" =~ ^.*/.*$ ]] || path=${DEFAULT_PATH}${path}

    podman load -i ${path}
}

#Docker exec
#Use bash as a default CMD, if no container is specified, use last container from docker ps list
function de() {
    local cmd=bash
    local container=$1
    [ -z "$1" ] && container=$(podman ps | tail -1 | awk '{print $1}')
    [ "$container" == "CONTAINER" ] && >&2 echo "No running container" && return 0
    [ $# -ge 2 ] && shift && cmd=$@
    podman exec -it $container $cmd
}

#Docker inspect/ip
#Get an IP address of a container - if no container is specified, use last container from docker ps list
function di() {
    local container=$1
    [ -z "$1" ] && container=$(podman ps | tail -1 | awk '{print $1}')
    [ "$container" == "CONTAINER" ] && >&2 echo "No running container" && return 0
    podman inspect $container | jq -r .[0].NetworkSettings.IPAddress
}

#Docker kill
#Kill the specified container, if no container is specified, use last container from docker ps list
function dk() {
    local container=$1
    [ -z "$1" ] && container=$(podman ps | tail -1 | awk '{print $1}')
    [ "$container" == "CONTAINER" ] && >&2 echo "No running container" && return 0
    podman kill $container
}

function docker-build() {
    dockerfile="Dockerfile"
    [ -e "$dockerfile" ] || return 1
    build_cmd=$(cat $dockerfile | grep LABEL | grep -i build | cut -d " " -f 3-)

    echo "Running a Build label from $dockerfile: $build_cmd"
    $build_cmd
}

function oc-cat() {
    f=$1
    shift
    for i in $@; do
        echo "================= $i - $f ===================="
        oc exec -it $i -- cat $f
    done
}

function oc-tail() {
    f=$1
    shift
    for i in $@; do
        echo "================= $i - $f ===================="
        oc exec -it $i -- tail -f $f
    done
}

function ph() {
    ps -eo size,pid,user,command --sort -size | awk '{ hr=$1/1024 ; printf("%13.2f Mb ",hr) } { for ( x=4 ; x<=NF ; x++ ) { printf("%s ",$x) } print "" }'
}

function occ() {
    CONTEXT=""
    if [ -n $1 ]; then
        CONTEXT=$1
    fi

    oc config get-contexts | grep "$CONTEXT" | sed 's/[* ]*//' | awk '{print $1}'
}

function ocuc() {
    if [ $# -lt 1 ]; then
        echo "Missing argument CONTEXT"
        return 1
    fi

    oc config use-context $1
}

function gfrb() {
    local NEW_BRANCH=$1

    git checkout master || git checkout main || return $?
    git fetch upstream || return $?
    git rebase upstream/master || git rebase upstream/main ||  return $?

    if [ -n "${NEW_BRANCH}" ]; then
        git checkout -b ${NEW_BRANCH} || return $?
    else
        echo "No branch given, there was no new branch created" > /dev/stderr
    fi
}

function gppr() {
    local BRANCH=$(git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')
    local URL=$(git config --get remote.upstream.url | sed 's/.git$//')/compare/master...${USERNAME}:${BRANCH}?expand=1

    git push
    [ $? -eq 128 ] && (echo "Push failed, pushing git push --set-upstream origin ${BRANCH}" && git push --set-upstream origin ${BRANCH} && xdg-open ${URL})
}

function grau() {
    git remote add upstream $1
}

