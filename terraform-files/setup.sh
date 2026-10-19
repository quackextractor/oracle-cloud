#!/bin/sh
# Runs ON the server (deploy.sh calls it). Starts the jackpot container.
set -eu
cd "$(dirname "$0")"
chmod 600 oci_api_key.pem terraform.tfvars
UID=$(id -u) GID=$(id -g) docker compose up -d --force-recreate
echo "jackpot container running. Follow it with:  docker logs -f oracle-cloud-jackpot-1"
