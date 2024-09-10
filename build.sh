# use dedicated container for each copy of the repository
CONTAINER_ID="builder_$(pwd | md5sum | head -c 8)"
REPO_ROOT=$(git rev-parse --show-toplevel)

GIT_DIR=$(git rev-parse --git-dir)
CONTAINER_NAME="test_container"

docker build -t $CONTAINER_NAME \
    --no-cache \
    --build-arg USER_ID=$(id -u) \
    --build-arg GROUP_ID=$(id -g) \
    --build-arg USER=$USER \
    .
