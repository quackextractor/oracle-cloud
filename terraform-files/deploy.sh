#!/usr/bin/env bash
# Usage: ./deploy.sh [ssh-host]   (default: server)
# Copies this folder (config + secrets) to the server and starts the retry service there.
# The state file is copied only once; after that the server owns it. Do NOT run terraform locally anymore.
set -eu
HOST=${1:-server}
REMOTE=oracle-cloud
cd "$(dirname "$0")"
tar --exclude=.terraform --exclude='*.tfstate*' --exclude=tfplan -czf - . | ssh "$HOST" "mkdir -p $REMOTE && tar -xzf - -C $REMOTE"
ssh "$HOST" "test -e $REMOTE/terraform.tfstate" || scp -q terraform.tfstate "$HOST:$REMOTE/"
ssh "$HOST" "sh $REMOTE/setup.sh"
