#!/bin/sh
# Runs ON the server (deploy.sh calls it). Starts the jackpot container.
set -eu
cd "$(dirname "$0")"
chmod 600 oci_api_key.pem terraform.tfvars
UID=$(id -u) GID=$(id -g) docker compose up -d --force-recreate
echo "jackpot container running. Check it with ./status.sh, or follow it with: tail -f ~/oracle-cloud/jackpot.log"
