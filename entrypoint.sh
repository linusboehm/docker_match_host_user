#!/bin/bash

set -eu

# Adjust ownership of the /app directory
# chown -R $(id -u):$(id -g) /app

echo "running entrypoint script... "

# Update the UID and GID of the user
if [ ! -z "$USER_ID" ] && [ ! -z "$GROUP_ID" ]; then
    usermod -u $USER_ID user
    groupmod -g $GROUP_ID user
    chown -R user:user /home/user
fi

# Execute the given command as the specified user
echo "setup complete, running: $@"
# exec gosu user "$@
set -- gosu user "$@"
exec "$@"

# # Then execute the Docker CMD
# echo "setup complete, running: $@"
# eval "bash -c '$@'"
