#!/bin/bash

set -ue

CONTAINTER_NAME_PREFIX="builder"
CONTAINER_NAME="test_container"

print_help() {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -h, --help           Show this help message and exit."
    echo "  -n, --name           Set prefix for docker container name."
    echo ""
}

### COMMAND LINE ARGS
TEMP=$(getopt -o hn: \
    --long help,name: \
    -- "$@")
RET_CODE=$?
if [ $RET_CODE != 0 ]; then
    echo "Terminating..." >&2
    exit 1
fi
eval set -- "$TEMP"

# process args
while true; do
    case "$1" in
        -h | --help)        print_help; exit 0 ;;
        -n | --name) CONTAINTER_NAME_PREFIX="$2"; shift 2 ;;
        -- ) shift; break ;;
        * ) break ;;
    esac
done
### ~COMMAND LINE ARGS

# use dedicated container for each copy of the repository
CONTAINER_ID="${CONTAINTER_NAME_PREFIX}_$(pwd | md5sum | head -c 8)"
REPO_ROOT=$(git rev-parse --show-toplevel)

# just RUN (docker could also be left running with -d and then command send later with docker exec)
echo "mounting ${REPO_ROOT}"
sudo docker run --name $CONTAINER_ID -it --rm \
    -e "REPO_ROOT=$REPO_ROOT" \
    -e "USER_ID=$(id -u)" \
    -e "GROUP_ID=$(id -g)" \
    --volume $REPO_ROOT:$REPO_ROOT \
    $CONTAINER_NAME bash -c "cd $REPO_ROOT; $*; cd $REPO_ROOT"
