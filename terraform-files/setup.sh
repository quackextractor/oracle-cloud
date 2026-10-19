#!/usr/bin/env bash
# Runs ON the server (deploy.sh calls it). Installs terraform if missing, installs + starts the jackpot service.
set -eu
cd "$(dirname "$0")"
chmod 600 oci_api_key.pem terraform.tfvars
chmod +x jackpot.sh
if ! command -v terraform >/dev/null; then
  . /etc/os-release
  wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --batch --yes -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $VERSION_CODENAME main" | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -qq && sudo apt-get install -y -qq terraform
fi
sed "s|__USER__|$USER|;s|__DIR__|$PWD|" jackpot.service | sudo tee /etc/systemd/system/jackpot.service >/dev/null
sudo systemctl daemon-reload
sudo systemctl enable jackpot >/dev/null
sudo systemctl restart jackpot
echo "jackpot service running. Follow it with:  journalctl -u jackpot -f"
